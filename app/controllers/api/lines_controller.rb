class Api::LinesController < ApplicationController
  require 'line/bot'

  DEFAULT_SLEEP = 1.freeze

  # set :app_base_url, ENV['APP_BASE_URL']
  protect_from_forgery with: :null_session

  def make_client(id,secret,token)
    @client ||= Line::Bot::Client.new do |config|
      config.channel_id = id
      config.channel_secret = secret
      config.channel_token = token
      config.http_options = {
        open_timeout: 5,
        read_timeout: 5,
      }
    end
  end

  def reply_text(event, texts)
    texts = [texts] if texts.is_a?(String)
    @client.reply_message(
      event['replyToken'],
      texts.map { |text| {type: 'text', text: text} }
      )
  end

  def reply_content(event, messages)
    res = @client.reply_message(
      event['replyToken'],
      messages
      )
    logger.warn res.read_body unless Net::HTTPOK === res
    render json: messages, status: :ok
  end

  def callback
    body = request.body.read
    @parsed_body = JSON.parse(body)
    user_id = @parsed_body['events'][0]['source']['userId']
    destination = @parsed_body['destination']
    link_channel(user_id,destination)

    @channel_destination = @parsed_body['destination']
    channel = Channel.find_by(channel_destination: @channel_destination)
    if channel.present?
      @channel = channel.channel_name
      @channel_id = channel.channel_id
      secret = channel.channel_secret
      token = channel.channel_token

      @client = make_client(@channel_id,secret,token)
    else
      return
    end

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless @client.validate_signature(body, signature)
      halt 400, {'Content-Type' => 'text/plain'}, 'Bad Request'
    end
    events = @client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        handle_message(event)

      when Line::Bot::Event::Follow
        profile = @client.get_profile(event['source']['userId'])
        profile = JSON.parse(profile.read_body)

        fr_account = event['source']['userId']

        friend = Friend.find_by(fr_account: fr_account)
        if friend.blank?
          friend = add_friend(fr_account,profile['displayName'],profile['pictureUrl'],profile['statusMessage'],@channel_destination)
        else
          unblock(fr_account)
        end
        option = Option.find_by(channel_id: @channel_id, option_type: 'welcomeReply')
        if option.present?
          if option.bool&&!friend.block_at.present?
            send_welcome_message(option,event)
          elsif option.remind_bool&&friend.block_at.present?
            send_welcome_message(option,event)
          end
        end

      when Line::Bot::Event::Unfollow
        logger.info "[UNFOLLOW]\n#{body}"
        fr_account = event['source']['userId']
        block(fr_account)

      when Line::Bot::Event::Join
        reply_text(event, "[JOIN]\n#{event['source']['type']}")

      when Line::Bot::Event::Leave
        logger.info "[LEAVE]\n#{body}"

      when Line::Bot::Event::Postback
        dateInfo = "#{JSON.generate(event['postback']['params'])}"
        if dateInfo != 'null'
          message = "#{event['postback']['data']} (#{dateInfo})"
        else
          fr_account = event['source']['userId']
          friend = Friend.find_by(fr_account: fr_account)
          sender = friend.fr_name
          receiver = @channel
          channel_destination = @channel_destination
          data = "#{event['postback']['data']}"
          reply_token = event['replyToken']
          event_type = event['type']
          fr_account = event['source']['userId']

          postback = Postback.new({
            sender: sender, receiver: receiver, data: data, fr_account: fr_account, channel_destination: channel_destination, reply_token: reply_token
          })
          bool_postback = save_postback(postback)
          message = Message.new({sender: @channel, receiver: sender, message_id: "", fr_account: fr_account, channel_destination: channel_destination, reply_token: reply_token, check_status: 'answered'})
          option_checker(event,message)
        end

      when Line::Bot::Event::Beacon
        reply_text(event, "[BEACON]\n#{JSON.generate(event['beacon'])}")

      when Line::Bot::Event::Things
        reply_text(event, "[THINGS]\n#{JSON.generate(event['things'])}")

      else
        reply_text(event, "Unknown event type: #{event}")
      end
    end
    "OK"
  end

  def link_channel(user_id,destination)
    channel = Channel.find_by(channel_user_id: user_id)
    if channel.present?
      channel.update(channel_destination: destination)
    end
  end

  def send_welcome_message(option,event)
    reaction_ids = option.match_reaction.split(",")
    contents_array = []
    reaction_ids.each do |id|
      reaction = Reaction.find(id.to_i)
      case reaction.reaction_type
      when "text"
        contents = contents_converter(reaction.contents)
        contents = {
          'type': 'text',
          'text': contents
        }
        contents_array.push(contents)
      when "stamp"
        contents = {
          type: 'sticker',
          packageId: 1,
          stickerId: reaction.contents[2..reaction.contents.length].to_i
        }
        contents_array.push(contents)
      when "image"
        address = reaction.image.url.to_s
        contents = {
          type: "image",
          originalContentUrl: address,
          previewImageUrl: address
        }
        contents_array.push(contents)
      when "map"
        map_array = map_converter(reaction.contents)
        latlng_array = map_array[1].split(',')
        contents = {
          type: "location",
          title: "位置情報",
          address: map_array[0],
          latitude: latlng_array[0],
          longitude: latlng_array[1]
        }
        contents_array.push(contents)
      when "carousel"
        bubble_list = []
        bubble_ids = reaction.contents.split(",")
        bubble_ids.each do |id|
          bubble = Bubble.find(id)
          bubble_list.push(bubble_converter(bubble))
        end
        contents = {
          type: "flex",
          altText: "this is a flex carousel",
          contents: {
            type: "carousel",
            contents: bubble_list
          }
        }
        contents_array.push(contents)
      end
    end
    reply_content(event,contents_array)
  end

  def bubble_converter(bubble)
    converted_bubble = { type: "bubble" }
    if bubble.header.present?
      converted_bubble[:header] = header_converter(bubble.header, bubble.header_gravity, bubble.header_align,
        bubble.header_size, bubble.header_bold, bubble.header_color, bubble.header_background)
    end
    if bubble.image.present?
      converted_bubble[:hero] = image_converter(bubble.image, bubble.hero_align, bubble.hero_size, bubble.hero_background, bubble.hero_ratio)
    end
    if bubble.body.present?
      converted_bubble[:body] = body_converter(bubble.body, bubble.body_gravity, bubble.body_align, bubble.body_size,
        bubble.body_bold, bubble.body_color, bubble.body_background)
    end
    if bubble.footer.present?
      converted_bubble[:footer] = footer_converter(bubble.footer, bubble.footer_gravity, bubble.footer_align,
        bubble.footer_size, bubble.footer_bold, bubble.footer_color, bubble.footer_background, bubble.footer_type,
        bubble.footer_button, bubble.footer_uri, bubble.footer_message,bubble.footer_data)
    end

    return converted_bubble
  end

  def header_converter(header,gravity,align,size,bold,color,background)
    case gravity
    when "top"
      offsetBottom = "15px"
    when "center"
      offsetBottom = "0px"
    when "bottom"
      offsetBottom = "-15px"
    end
    converted_header = {
      type: "box",
      layout: "vertical",
      contents: [
        {
          type: "text",
          text: header,
          color: color,
          position: "relative",
          offsetBottom: offsetBottom,
          size: size,
          weight: bold,
          align: align,
          wrap: true
        }
      ],
      backgroundColor: background
    }
    return converted_header
  end

  def image_converter(image,align,size,background,ratio)
    converted_image = {
      type: "image",
      url: image.url,
      align: align,
      size: size,
      aspectRatio: ratio,
      backgroundColor: background
    }
    return converted_image
  end

  def body_converter(body,gravity,align,size,bold,color,background)
    body = contents_converter(body)
    case gravity
    when "top"
      offsetBottom = "20px"
    when "center"
      offsetBottom = "5px"
    when "bottom"
      offsetBottom = "-10px"
    end
    converted_body = {
      type: "box",
      layout: "vertical",
      contents: [
        {
          type: "text",
          text: body,
          position: "relative",
          offsetBottom: offsetBottom,
          align: align,
          size: size,
          weight: bold,
          color: color,
          wrap: true
        }
      ],
      backgroundColor: background
    }
    return converted_body
  end

  def footer_converter(footer,gravity,align,size,bold,color,background,type,button,uri,message,data)
    if type == 'button'
      if color=='#ffffff'
        color = "primary"
      else
        color = "secondary"
      end

      if button == 'uri'
        if !uri.include? "http"
          uri = "https://"+uri
        end
        data = {
          type: "button",
          style: color,
          action: {
            type: "uri",
            label: footer,
            uri: uri,
          },
          color: background
        }
      elsif button=='message'
        data = {
          type: "button",
          style: color,
          action: {
            type: "message",
            label: footer,
            text: message
          },
          color: background
        }
      elsif button=='postback'
        data = {
          type: "button",
          style: color,
          action: {
            type: "postback",
            label: footer,
            data: data
          },
          color: background
        }
        if message.present?
          data[:action][:text] = message
        end
      end
      converted_footer = {
        type: "box",
        layout: "horizontal",
        contents: [data]
      }
    else
      case gravity
      when "top"
        offsetBottom = "10px"
      when "center"
        offsetBottom = "0px"
      when "bottom"
        offsetBottom = "-10px"
      end
      data = {
        type: "text",
        text: footer,
        align: align,
        position: "relative",
        offsetBottom: offsetBottom,
        size: size,
        weight: bold,
        color: color,
        wrap: true
      }
      converted_footer = {
        type: "box",
        layout: "horizontal",
        contents: [data],
        backgroundColor: background
      }
    end

    return converted_footer
  end

  def handle_message(event)
    check_user(event)
    case event.type
    when Line::Bot::Event::MessageType::Image
      message_id = event.message['id']
      response = @client.get_message_content(message_id)
      tf = Tempfile.open("content")
      tf.write(response.body)
      reply_text(event, "[MessageType::IMAGE]\nid:#{message_id}\nreceived #{tf.size} bytes data")
    when Line::Bot::Event::MessageType::Video
      message_id = event.message['id']
      response = @client.get_message_content(message_id)
      tf = Tempfile.open("content")
      tf.write(response.body)
      reply_text(event, "[MessageType::VIDEO]\nid:#{message_id}\nreceived #{tf.size} bytes data")
    when Line::Bot::Event::MessageType::Audio
      message_id = event.message['id']
      response = @client.get_message_content(message_id)
      tf = Tempfile.open("content")
      tf.write(response.body)
      reply_text(event, "[MessageType::AUDIO]\nid:#{message_id}\nreceived #{tf.size} bytes data")
    when Line::Bot::Event::MessageType::File
      message_id = event.message['id']
      response = @client.get_message_content(message_id)
      tf = Tempfile.open("content")
      tf.write(response.body)
      reply_text(event, "[MessageType::FILE]\nid:#{message_id}\nfileName:#{event.message['fileName']}\nfileSize:#{event.message['fileSize']}\nreceived #{tf.size} bytes data")
    when Line::Bot::Event::MessageType::Sticker
      handle_sticker(event)
    when Line::Bot::Event::MessageType::Location
      handle_location(event)
    when Line::Bot::Event::MessageType::Text
      if event['source']['type'] == 'user'
        profile = @client.get_profile(event['source']['userId'])
        profile = JSON.parse(profile.read_body)
        channel_destination = @channel_destination
        reply_token = event['replyToken']
        event.message['text'] = unicode_converter(event.message['text'])
        @message = Message.new({sender: profile['displayName'], receiver: @channel, contents: event.message['text'], message_type: 'text', message_id: event.message['id'], sticker_id: nil, package_id: nil, fr_account: profile['userId'], channel_destination: channel_destination, reply_token: reply_token, check_status: 'unchecked'})
        save_message(@message)
        update_friend_info(profile['userId'],profile['displayName'],profile['pictureUrl'],profile['statusMessage'],channel_destination,@message.contents)

        message = Message.new({sender: @channel, receiver: profile['displayName'], message_id: event.message['id'],fr_account: profile['userId'], channel_destination: channel_destination, reply_token: reply_token, check_status: 'answered'})
        auto_reply = option_checker(event,message)
      else
        reply_text(event, "Bot can't use profile API without user ID")
      end
    else
      logger.info "Unknown message type: #{event.type}"
      reply_text(event, "[UNKNOWN]\n#{event.type}")
    end
  end

  def check_user(event)
    fr_account = event['source']['userId']
    channel_destination = @channel_destination
    friend = Friend.find_by(fr_account: fr_account)
    if friend.present?
      puts "user check success"
    else
      response = @client.get_profile(fr_account)
      case response
      when Net::HTTPSuccess then
        contact = JSON.parse(response.body)
        fr_name = contact['displayName']
        profile_pic = contact['pictureUrl']
        profile_msg = contact['statusMessage']
        add_friend(fr_account,fr_name,profile_pic,profile_msg,channel_destination)
      else
        p "#{response.code} #{response.body}"
      end
    end
  end

  def handle_sticker(event)
    profile = @client.get_profile(event['source']['userId'])
    profile = JSON.parse(profile.read_body)
    messages = [{
      type: 'sticker',
      packageId: "#{event.message['packageId']}",
      stickerId: "#{event.message['stickerId']}"
    }]

    channel_destination = @channel_destination
    reply_token = event['replyToken']
    sticker_id = event.message['stickerId']
    package_id = event.message['packageId']
    @message = Message.new({sender: profile['displayName'], receiver: @channel, contents: "#{package_id}_#{sticker_id}", message_type: 'stamp', message_id: event.message['id'], sticker_id: sticker_id, package_id: package_id, fr_account: profile['userId'], channel_destination: channel_destination, reply_token: reply_token, check_status: 'unchecked'})
    save_message(@message)

    contents = '<img src="https://cdn.lineml.jp/api/media/sticker/' + @message.contents + '" style="width: 30px;">'
    update_friend_info(profile['userId'],profile['displayName'],profile['pictureUrl'],profile['statusMessage'],channel_destination,contents)
    reply_content(event, messages)
  end

  def handle_location(event)
    message = event.message
    reply_content(event, {
      type: 'location',
      title: message['title'] || message['address'],
      address: message['address'],
      latitude: message['latitude'],
      longitude: message['longitude']
    })
  end

  def save_postback(postback)
    if postback.save
      return true
    else
      return false
    end
  end

  def save_message(message)
    if message.save
      # render :index, status: :ok
      puts "message saved"
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def add_friend(fr_account,fr_name,profile_pic,profile_msg,channel_destination)
    @friend = Friend.new({fr_account: fr_account, fr_name: fr_name, profile_pic: profile_pic, profile_msg: profile_msg, channel_destination: channel_destination})
    if @friend.save
      return @friend
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def block(fr_account)
    friend = Friend.where(fr_account: fr_account)
    now = Time.new
    if friend.update(block: 1, block_at: now)
      render html: '/api/friends', status: :ok
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def unblock(fr_account)
    @friend = Friend.where(fr_account: fr_account)
    now = Time.new
    if @friend.update(block: 0, follow_at: now)
      return @friend
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def update_friend_info(fr_account,fr_name,profile_pic,profile_msg,channel_destination,contents)
    channel = Channel.find_by(channel_destination: channel_destination)
    @channel = channel.channel_name
    @friend = Friend.find_by(fr_account: fr_account)
    time = Time.new
    if @friend.update(fr_name: fr_name, profile_pic: profile_pic, profile_msg: profile_msg,channel_destination: channel_destination,last_message_time: time,last_message: contents)
      update_message_profile(fr_account,fr_name,@channel)
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def update_message_profile(fr_account,fr_name,channel)
    @messages = Message.where(fr_account: fr_account, receiver: channel)
    if @messages.update(sender: fr_name)
      messages = Message.where(fr_account: fr_account, sender: channel)
      if messages.update(receiver: fr_name)
        puts "profile updated"
      else
        render json: @message.errors, status: :unprocessable_entity
      end
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def create_notify
    contents = params[:contents]
    notify_type = params[:notify_type]
    image = params[:image]
    target_tag = params[:target_tag]
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.attributes["channel_destination"]
    sender = @channel.channel_name
    if target_tag.present?
      puts target_tag
    else
      receiver = 'ALL'
    end

    @notify = Notify.new({sender: sender, receiver: receiver, contents: contents, notify_type: notify_type, channel_destination: channel_destination, image: image})

    # if @notify.notify_type == "text"
    #   broadcast_text(channel_destination,contents)
    # elsif @notify.notify_type == "stamp"
    #   broadcast_stamp(channel_destination,contents)
    # elsif @notify.notify_type == "image"
    #   broadcast_image(channel_destination,@notify.image)
    # elsif @notify.notify_type == "text+image"
    #   broadcast_text(channel_destination,contents)
    #   broadcast_image(channel_destination,@notify.image)
    # elsif @notify.notify_type == "map"
    #   address_array = map_converter(contents)
    #   broadcast_map(channel_destination,address_array)
    #   @notify.contents = address_array[0]
    # elsif @notify.notify_type == "carousel"
    #   broadcast_carousel(channel_destination,contents)
    # end
    if @notify.save
      render json: @notify, status: :ok
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def map_converter(contents)
    address_array = contents.split('+')
    address_array[0] = address_array[0].gsub(/日本、/,'')
    address_array[1] = address_array[1].gsub(/\[@map\(/,'').gsub(/\)]/,'')
    return address_array
  end

  def broadcast_text(channel_destination,contents)
    contents = contents_converter(contents)
    message = {
      "type": "text",
      "text": "["+current_user.group+"]\n"+contents
    }
    client = client_selecter(channel_destination)
    client.broadcast(message)
  end

  def client_selecter(channel_destination)
    channel = Channel.find_by(channel_destination: channel_destination)
    id = channel.channel_id
    secret = channel.channel_secret
    token = channel.channel_token
    @client = make_client(id,secret,token)
    return @client
  end

  def broadcast_stamp(channel_destination,contents)
    message = {
      type: 'sticker',
      packageId: 1,
      stickerId: contents[2..contents.length].to_i
    }
    client = client_selecter(channel_destination)
    client.broadcast(message)
  end

  def broadcast_image(channel_destination,url)
    address = url.to_s
    message = {
      type: "image",
      originalContentUrl: address,
      previewImageUrl: address
    }
    client = client_selecter(channel_destination)
    client.broadcast(message)
  end

  def broadcast_map(channel_destination,arr)
    mapArray = arr[1].split(',')
    message = {
      "type": "location",
      "title": "位置情報",
      "address": arr[0],
      "latitude": mapArray[0],
      "longitude": mapArray[1]
    };
    client = client_selecter(channel_destination)
    client.broadcast(message)
  end

  def broadcast_carousel(channel_destination,contents)
    bubble_list = []
    bubble_ids = contents.split(",")
    bubble_ids.each do |id|
      bubble = BubblesArchive.find(id)
      bubble_list.push(bubble_converter(bubble))
    end
    message = {
      type: "flex",
      altText: "this is a flex carousel",
      contents: {
        type: "carousel",
        contents: bubble_list
      }
    }
    client = client_selecter(channel_destination)
    client.broadcast(message)
  end

  def unicode_converter(text)
    if text.include?"(waving hand)"
      result = include_check("(waving hand)")
      text = text.gsub("(waving hand)",result)
    elsif text.include?"(love)"
      result = include_check("(love)")
      text = text.gsub("(love)",result)
    elsif text.include?"(hahaha)"
      result = include_check("(hahaha)")
      text = text.gsub("(hahaha)", result)
    elsif text.include?"(please!)"
      result = include_check("(please)")
      text = text.gsub("(please!)",result)
    elsif text.include?"(shocked)"
      result = include_check("(shocked)")
      text = text.gsub("(shocked)",result)
    elsif text.include?"(sad)"
      result = include_check("(sad)")
      text = text.gsub("(sad)",result)
    elsif text.include?"(oh no!)"
      result = include_check("(oh no!)")
      text = text.gsub("(oh no!)",result)
    elsif text.include?"(super angry)"
      result = include_check("(super angry)")
      text = text.gsub("(super angry)",result)
    elsif text.include?"(hee)"
      result = include_check("(hee)")
      text = text.gsub("(hee)",result)
    elsif text.include?"(moon grin)"
      result = include_check("(moon grin)")
      text = text.gsub("(moon grin)",result)
    elsif text.include?"(oops)"
      result = include_check("(oops)")
      text = text.gsub("(oops)",result)
    elsif text.include?"(moon wink)"
      result = include_check("(moon wink)")
      text = text.gsub("(moon wink)",result)
    elsif text.include?"(content)"
      result = include_check("(content)")
      text = text.gsub("(content)",result)
    elsif text.include?"(gasp)"
      result = include_check("(gasp)")
      text = text.gsub("(gasp)",result)
    elsif text.include?"(blue)"
      result = include_check("(blue)")
      text = text.gsub("(blue)",result)
    elsif text.include?"(nom nom)"
      result = include_check("(nom nom)")
      text = text.gsub("(nom nom)",result)
    elsif text.include?"(ah...)"
      result = include_check("(ah...)")
      text = text.gsub("(ah...)",result)
    elsif text.include?"(at last!)"
      result = include_check("(at last!)")
      text = text.gsub("(at last!)",result)
    elsif text.include?"(haha)"
      result = include_check("(haha)")
      text = text.gsub("(haha)",result)
    elsif text.include?"(sparkling eyes)"
      result = include_check("(sparkling eyes)")
      text = text.gsub("(sparkling eyes)",result)
    elsif text.include?"(kiss me)"
      result = include_check("(kiss me)")
      text = text.gsub("(kiss me)",result)
    elsif text.include?"(tongue out)"
      result = include_check("(tongue out)")
      text = text.gsub("(tongue out)",result)
    elsif text.include?"(frozen)"
      result = include_check("(frozen)")
      text = text.gsub("(frozen)",result)
    elsif text.include?"(kony kiss)"
      result = include_check("(kony kiss)")
      text = text.gsub("(kony kiss)",result)
    elsif text.include?"(hmph)"
      result = include_check("(hmph)")
      text = text.gsub("(hmph)",result)
    elsif text.include?"(brr)"
      result = include_check("(brr)")
      text = text.gsub("(brr)",result)
    elsif text.include?"(half dead)"
      result = include_check("(half dead)")
      text = text.gsub("(half dead)",result)
    elsif text.include?"(sharp)"
      result = include_check("(sharp)")
      text = text.gsub("(sharp)",result)
    elsif text.include?"(panic)"
      result = include_check("(panic)")
      text = text.gsub("(panic)",result)
    elsif text.include?"(doze off)"
      result = include_check("(doze off)")
      text = text.gsub("(doze off)",result)
    elsif text.include?"(aww)"
      result = include_check("(aww)")
      text = text.gsub("(aww)",result)
    elsif text.include?"(argh!)"
      result = include_check("(argh!)")
      text = text.gsub("(argh!)",result)
    elsif text.include?"(brown)"
      result = include_check("(brown)")
      text = text.gsub("(brown)",result)
    elsif text.include?"(eh?!)"
      result = include_check("(eh?!)")
      text = text.gsub("(eh?!)",result)
    elsif text.include?"(goodnight)"
      result = include_check("(goodnight)")
      text = text.gsub("(goodnight)",result)
    elsif text.include?"(stressed)"
      result = include_check("(stressed)")
      text = text.gsub("(stressed)",result)
    elsif text.include?"(worn out)"
      result = include_check("(worn out)")
      text = text.gsub("(worn out)",result)
    elsif text.include?"(what?!)"
      result = include_check("(what?!)")
      text = text.gsub("(what?!)",result)
    elsif text.include?"(james wink)"
      result = include_check("(james wink)")
      text = text.gsub("(james wink)",result)
    elsif text.include?"(attracted)"
      result = include_check("(attracted)")
      text = text.gsub("(attracted)",result)
    elsif text.include?"(who, me?)"
      result = include_check("(who, me?)")
      text = text.gsub("(who, me?)",result)
    elsif text.include?"(happy)"
      result = include_check("(happy)")
      text = text.gsub("(happy)",result)
    elsif text.include?"(smile)"
      result = include_check("(smile)")
      text = text.gsub("(smile)",result)
    elsif text.include?"(laugh)"
      result = include_check("(laugh)")
      text = text.gsub("(laugh)",result)
    elsif text.include?"(blush)"
      result = include_check("(blush)")
      text = text.gsub("(blush)",result)
    elsif text.include?"(wink)"
      result = include_check("(wink)")
      text = text.gsub("(wink)",result)
    elsif text.include?"(glad)"
      result = include_check("(glad)")
      text = text.gsub("(glad)",result)
    elsif text.include?"(glow kiss)"
      result = include_check("(glow kiss)")
      text = text.gsub("(glow kiss)",result)
    elsif text.include?"(kiss)"
      result = include_check("(kiss)")
      text = text.gsub("(kiss)",result)
    elsif text.include?"(baffled)"
      result = include_check("(baffled)")
      text = text.gsub("(baffled)",result)
    elsif text.include?"(relief)"
      result = include_check("(relief)")
      text = text.gsub("(relief)",result)
    elsif text.include?"(grin)"
      result = include_check("(grin)")
      text = text.gsub("(grin)",result)
    elsif text.include?"(kidding)"
      result = include_check("(kidding)")
      text = text.gsub("(kidding)",result)
    elsif text.include?"(funny)"
      result = include_check("(funny)")
      text = text.gsub("(funny)",result)
    elsif text.include?"(unamused)"
      result = include_check("(unamused)")
      text = text.gsub("(unamused)",result)
    elsif text.include?"(smirk)"
      result = include_check("(smirk)")
      text = text.gsub("(smirk)",result)
    elsif text.include?"(bittersmile)"
      result = include_check("(bittersmile)")
      text = text.gsub("(bittersmile)",result)
    elsif text.include?"(hm)"
      result = include_check("(hm)")
      text = text.gsub("(hm)",result)
    elsif text.include?"(disappointed)"
      result = include_check("(disappointed)")
      text = text.gsub("(disappointed)",result)
    elsif text.include?"(unbearable)"
      result = include_check("(unbearable)")
      text = text.gsub("(unbearable)",result)
    elsif text.include?"(coldsweat)"
      result = include_check("(coldsweat)")
      text = text.gsub("(coldsweat)",result)
    elsif text.include?"(exasperated)"
      result = include_check("(exasperated)")
      text = text.gsub("(exasperated)",result)
    elsif text.include?"(anguished)"
      result = include_check("(anguished)")
      text = text.gsub("(anguished)",result)
    elsif text.include?"(tired)"
      result = include_check("(tired)")
      text = text.gsub("(tired)",result)
    elsif text.include?"(tear)"
      result = include_check("(tear)")
      text = text.gsub("(tear)",result)
    elsif text.include?"(crying)"
      result = include_check("(crying)")
      text = text.gsub("(crying)",result)
    elsif text.include?"(tearsofjoy)"
      result = include_check("(tearsofjoy)")
      text = text.gsub("(tearsofjoy)",result)
    elsif text.include?"(astonished)"
      result = include_check("(astonished)")
      text = text.gsub("(astonished)",result)
    elsif text.include?"(scream)"
      result = include_check("(scream)")
      text = text.gsub("(scream)",result)
    elsif text.include?"(pouting)"
      result = include_check("(pouting)")
      text = text.gsub("(pouting)",result)
    elsif text.include?"(angry)"
      result = include_check("(angry)")
      text = text.gsub("(angry)",result)
    elsif text.include?"(dozing)"
      result = include_check("(dozing)")
      text = text.gsub("(dozing)",result)
    elsif text.include?"(mask)"
      result = include_check("(mask)")
      text = text.gsub("(mask)",result)
    elsif text.include?"(dazed)"
      result = include_check("(dazed)")
      text = text.gsub("(dazed)",result)
    elsif text.include?"(catface)"
      result = include_check("(catface)")
      text = text.gsub("(catface)",result)
    elsif text.include?"(yummy)"
      result = include_check("(yummy)")
      text = text.gsub("(yummy)",result)
    elsif text.include?"(pig)"
      result = include_check("(pig)")
      text = text.gsub("(pig)",result)
    elsif text.include?"(cat)"
      result = include_check("(cat)")
      text = text.gsub("(cat)",result)
    elsif text.include?"(dog)"
      result = include_check("(dog)")
      text = text.gsub("(dog)",result)
    elsif text.include?"(ghost)"
      result = include_check("(ghost)")
      text = text.gsub("(ghost)",result)
    elsif text.include?"(jack o'lantern)"
      result = include_check("(jack o'lantern)")
      text = text.gsub("(jack o'lantern)",result)
    elsif text.include?"(devil)"
      result = include_check("(devil)")
      text = text.gsub("(devil)",result)
    elsif text.include?"(skull and crossbones)"
      result = include_check("(skull and crossbones)")
      text = text.gsub("(skull and crossbones)",result)
    elsif text.include?"(poo)"
      result = include_check("(poo)")
      text = text.gsub("(poo)",result)
    elsif text.include?"(fire)"
      result = include_check("(fire)")
      text = text.gsub("(fire)",result)
    elsif text.include?"(yes)"
      result = include_check("(yes)")
      text = text.gsub("(yes)",result)
    elsif text.include?"(no)"
      result = include_check("(no)")
      text = text.gsub("(no)",result)
    elsif text.include?"(toilet)"
      result = include_check("(toilet)")
      text = text.gsub("(toilet)",result)
    elsif text.include?"(surprise)"
      result = include_check("(surprise)")
      text = text.gsub("(surprise)",result)
    elsif text.include?"(sweat)"
      result = include_check("(sweat)")
      text = text.gsub("(sweat)",result)
    elsif text.include?"(dash)"
      result = include_check("(dash)")
      text = text.gsub("(dash)",result)
    elsif text.include?"(zzz)"
      result = include_check("(zzz)")
      text = text.gsub("(zzz)",result)
    elsif text.include?"(libs)"
      result = include_check("(libs)")
      text = text.gsub("(libs)",result)
    elsif text.include?"(sparkle)"
      result = include_check("(sparkle)")
      text = text.gsub("(sparkle)",result)
    elsif text.include?"(eyes)"
      result = include_check("(eyes)")
      text = text.gsub("(eyes)",result)
    elsif text.include?"(ear)"
      result = include_check("(ear)")
      text = text.gsub("(ear)",result)
    elsif text.include?"(lightning)"
      result = include_check("(lightning)")
      text = text.gsub("(lightning)",result)
    elsif text.include?"(moon)"
      result = include_check("(moon)")
      text = text.gsub("(moon)",result)
    elsif text.include?"(sun)"
      result = include_check("(sun)")
      text = text.gsub("(sun)",result)
    elsif text.include?"(rain)"
      result = include_check("(rain)")
      text = text.gsub("(rain)",result)
    elsif text.include?"(snow)"
      result = include_check("(snow)")
      text = text.gsub("(snow)",result)
    elsif text.include?"(cloud)"
      result = include_check("(cloud)")
      text = text.gsub("(cloud)",result)
    elsif text.include?"(ok)"
      result = include_check("(ok)")
      text = text.gsub("(ok)",result)
    elsif text.include?"(boo)"
      result = include_check("(boo)")
      text = text.gsub("(boo)",result)
    elsif text.include?"(scissors)"
      result = include_check("(scissors)")
      text = text.gsub("(scissors)",result)
    elsif text.include?"(paper)"
      result = include_check("(paper)")
      text = text.gsub("(paper)",result)
    elsif text.include?"(rock)"
      result = include_check("(rock)")
      text = text.gsub("(rock)",result)
    elsif text.include?"(clap)"
      result = include_check("(clap)")
      text = text.gsub("(clap)",result)
    elsif text.include?"(!!)"
      result = include_check("(!!)")
      text = text.gsub("(!!)",result)
    elsif text.include?"(?)"
      result = include_check("(?)")
      text = text.gsub("(?)",result)
    elsif text.include?"(music note)"
      result = include_check("(music note)")
      text = text.gsub("(music note)",result)
    elsif text.include?"(heart)"
      result = include_check("(heart)")
      text = text.gsub("(heart)",result)
    elsif text.include?"(brokenheart)"
      result = include_check("(brokenheart)")
      text = text.gsub("(brokenheart)",result)
    elsif text.include?"(1 heart)"
      result = include_check("(1 heart)")
      text = text.gsub("(1 heart)",result)
    elsif text.include?"(3 hearts)"
      result = include_check("(3 hearts)")
      text = text.gsub("(3 hearts)",result)
    elsif text.include?"(hi)"
      result = include_check("(hi)")
      text = text.gsub("(hi)",result)
    end
    return text
  end

  def include_check(text)
    emoji = Emoji.find_by(moji_text: text)
    result = '<img src="' + emoji.attributes['img_url'] + '" style="width: 30px;">'
    return result
  end


  def option_checker(event,message)
    event_type = event['type']
    if event_type == 'message'
      @text = event.message['text']
    elsif event_type == 'postback'
      @text = event['postback']['data']
    end
    channel = Channel.find_by(channel_destination: @channel_destination)
    channel_id = channel.attributes["channel_id"]

    options = Option.where(channel_id: channel_id)
    if options.present?
      options.each do |option|
        if check_target(option,message)
          now = Time.new
          temp_array = option.target_day.split(",")
          if temp_array.include? now.wday.to_s
            tempArray = option.target_time.split(",")
            startTime = tempArray[0].delete(":").to_i
            endTime = tempArray[1].delete(":").to_i
            timeGap = endTime - startTime
            tempTime = now.strftime("%H%M").to_i
            if (timeGap >= 0 && ((startTime <= tempTime)&&(tempTime<=endTime)))||(timeGap < 0 && ((startTime <= tempTime)||(tempTime<=endTime))) || (startTime==0&&endTime==0)
              if option.target_keyword.present?
                tempArray = option.target_keyword.split(",")
                if tempArray.include? @text
                  if option.match_reaction.present?
                    action_ids = option.match_reaction.split(",")
                    if option.action_count.present?
                      if option.action_count > 0
                        option.update(action_count: option.action_count - 1)
                        send_by_option(event,action_ids,message)
                      end
                    else
                      send_by_option(event,action_ids,message)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def check_target(option,message)
    if option.target_friend.present?
      tempArray = option.target_friend.split(",")
      tempArray.each do |target|
        friend = Friend.find_by(fr_account: message.fr_account)
        if friend.tags.split(",").include? target
          return true
          break
        else
          return false
        end
      end
    else
      return true
    end
  end

  def send_by_option(event,array,message)
    reply_contents = []
    array.each do |id|
      reaction = Reaction.find(id)
      auto_message = Message.new({sender: message.sender, receiver: message.receiver, message_id: message.message_id+'a', fr_account: message.fr_account, channel_destination: message.channel_destination, reply_token: message.reply_token, check_status: message.check_status})
      case reaction.attributes["reaction_type"]
      when "text"
        auto_message.contents = reaction.attributes["contents"]
        contents = contents_converter(reaction.attributes["contents"])

        auto_message.message_type = 'text'
        auto_message.save
        contents = {
          type: 'text',
          text: contents
        }
        reply_contents.push(contents)
      when "stamp"
        stamp_id = reaction.attributes["contents"]
        contents = stamp_id
        auto_message.contents = contents
        auto_message.message_type = 'stamp'
        auto_message.package_id = 1
        auto_message.sticker_id = stamp_id[2..stamp_id.length].to_i
        auto_message.save
        contents = {
          type: 'sticker',
          packageId: 1,
          stickerId: auto_message.sticker_id
        }
        reply_contents.push(contents)
      when "image"
        address = reaction.image.url.to_s
        auto_message.contents = address
        auto_message.message_type = 'image'
        auto_message.image = reaction.image
        auto_message.save
        contents = {
          type: "image",
          originalContentUrl: address,
          previewImageUrl: address
        }
        reply_contents.push(contents)
      when "map"
        contents = reaction.attributes["contents"]
        auto_message.contents = contents
        auto_message.message_type = 'map'
        auto_message.save
        map_array = map_converter(contents)
        latlng_array = map_array[1].split(',')
        contents = {
          type: "location",
          title: "位置情報",
          address: map_array[0],
          latitude: latlng_array[0],
          longitude: latlng_array[1]
        }
        reply_contents.push(contents)
      when "text+image"
        contents = contents_converter(reaction.attributes["contents"])
        contents = {
          type: 'text',
          text: contents
        }
        address = reaction.image.url.to_s
        image = {
          type: "image",
          originalContentUrl: address,
          previewImageUrl: address
        }
        auto_message.contents = contents
        auto_message.message_type = "text+image"
        auto_message.image = image
        reply_contents.push(contents)
        reply_contents.push(image)
      when "carousel"
        contents = ""
        bubble_list = []
        bubble_ids = reaction.contents.split(",")
        bubble_ids.each do |id|
          bubble = Bubble.find(id)
          bubble_list.push(bubble_converter(bubble))
          bubble_attributes = bubble.attributes

          image = bubble.image
          bubble_attributes[:image] = image
          bubble_attributes.delete("id")
          bubble_attributes.delete("created_at")
          bubble_attributes.delete("updated_at")
          @bubbles_archive = BubblesArchive.new(bubble_attributes)
          @bubbles_archive.save
          bubbles_archive = BubblesArchive.last
          contents = contents + bubbles_archive.id.to_s
        end

        auto_message.contents = contents
        auto_message.message_type = 'carousel'
        auto_message.save

        contents = {
          type: "flex",
          altText: "this is a flex carousel",
          contents: {
            type: "carousel",
            contents: bubble_list
          }
        }
        reply_contents.push(contents)
      end
    end
    update_msg = Message.where(sender: message.receiver, receiver: message.sender, reply_token: message.reply_token)
    if update_msg.present?
      update_msg.update({check_status: 'autoReplied'})
    end
    reply_content(event, reply_contents)
  end

  def contents_converter(contents)
    if contents.include?"<div>"
      contents = contents.gsub(/<div>/,"\n")
      contents = contents.gsub(/<\/div>/,'')
    end
    if contents.include?"<br>"
      contents = contents.gsub(/<br>/,'')
    end
    if contents.include?"&nbsp;"
      contents = contents.gsub(/&nbsp;/,' ')
    end
    if contents.include?"&amp;"
      contents = contents.gsub(/&amp;/,'&')
    end
    if contents.include?"&quot;"
      contents = contents.gsub(/&quot;/,'"')
    end
    if contents.include?"&lt;"
      contents = contents.gsub(/&lt;/,'<')
    end
    if contents.include?"&gt;"
      contents = contents.gsub(/&gt;/,'>')
    end
    if contents.include?"<span"
      contents = contents.gsub(/<span style="font-size: 20px;">/,'')
      contents = contents.gsub(/<\/span>/,'')
    end
    if contents.include?("<img src=")
      tempText = contents.gsub(/<img src="/,'^').gsub(/" style="width: 30px;">/,'^').gsub(/" style="font-size: 1rem; width: 30px;">/,'^')
      tempArray = tempText.split('^')
      tempArray.each_with_index do |text,index|
        if text.include? "https://cdn.lineml.jp/api/media/sticker/"
          @emoji = Emoji.find_by(img_url: text)
          tempArray[index] = ""
          tempArray[index] = @emoji['unicode']
        end
      end
      contents = ''
      tempArray.each do |t|
        contents = contents + t.force_encoding("UTF-8")
      end
    end
    return contents
  end

  def direct_reply
    message_id = params[:message_id]
    message = Message.find(message_id)
    message_type = params[:message_type]
    contents = params[:contents]
    image = params[:image]
    contents_array = []
    receiver = message.sender
    sender = message.receiver

    if image.present?
      message = Message.new({sender: sender, receiver: receiver, message_id: message.message_id+'a', fr_account: message.fr_account, channel_destination: message.channel_destination, reply_token: message.reply_token, check_status: 'answered', image: image})
    else
      message = Message.new({sender: sender, receiver: receiver, message_id: message.message_id+'a', fr_account: message.fr_account, channel_destination: message.channel_destination, reply_token: message.reply_token, check_status: 'answered', image: nil})
    end

    case message_type
    when "text"
      message.contents = contents
      message.message_type = 'text'
      contents = contents_converter(contents)
      contents = {
        'type': 'text',
        'text': contents
      }
      contents_array.push(contents)
    when "stamp"
      message.contents = contents
      message.message_type = 'stamp'
      message.package_id = 1
      message.sticker_id = contents[2..contents.length].to_i
      message.save

      contents = {
        type: 'sticker',
        packageId: 1,
        stickerId: contents[2..contents.length].to_i
      }
      contents_array.push(contents)
    when "image"
      message.contents = contents
      message.message_type = 'image'
      message.save
      address = message.image.url.to_s
      contents = {
        type: "image",
        originalContentUrl: address,
        previewImageUrl: address
      }
      contents_array.push(contents)
    when "map"
      message.contents = contents
      message.message_type = 'map'
      message.save
      map_array = map_converter(contents)
      latlng_array = map_array[1].split(',')
      contents = {
        type: "location",
        title: "位置情報",
        address: map_array[0],
        latitude: latlng_array[0],
        longitude: latlng_array[1]
      }
      contents_array.push(contents)
    when "carousel"
      message.contents = contents
      message.message_type = 'carousel'
      message.save
      bubble_list = []
      bubble_ids = contents.split(",")
      bubble_ids.each do |id|
        bubble = BubblesArchive.find(id)
        bubble_list.push(bubble_converter(bubble))
      end
      contents = {
        type: "flex",
        altText: "this is a flex carousel",
        contents: {
          type: "carousel",
          contents: bubble_list
        }
      }
      contents_array.push(contents)
    end
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)

    client = client_selecter(channel.channel_destination)
    client.push_message(message.fr_account, contents_array)

    if message.save
      update_replied(message.reply_token)
      render json: message, status: :ok
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  def update_replied(reply_token)
    @messages = Message.where(reply_token: reply_token).where.not(check_status: 'answered')
    @messages.each do |msg|
      msg.update(check_status: 'replied')
    end
  end

  def notify_again
    id = params[:id]
    notify = Notify.find(id)

    channel_destination = notify.channel_destination
    contents = notify.contents
    url = notify.image.url
    case notify.notify_type
    when "text"
      broadcast_text(channel_destination,contents)
    when "stamp"
      broadcast_stamp(channel_destination,contents)
    when "image"
      broadcast_image(channel_destination,url)
    when "map"
      address_array = map_converter(contents)
      broadcast_map(channel_destination,address_array)
    end
  end

  def set_richmenu
    @richmenu = Richmenu.new(richmenu_params)

    if @richmenu.save
      width = @richmenu.attributes["width"]
      height = @richmenu.attributes["height"]
      rich_name = @richmenu.attributes["name"]
      image = params[:image]
      selected = @richmenu.attributes["selected"]
      chat_bar_text = @richmenu.attributes["chat_bar_text"]
      contents = @richmenu.attributes["contents"]
      richaction_ids = contents.split(",")
      areas = []

      @richactions = Richaction.where(id: richaction_ids)

      @richactions.each do |richaction|
        area = {}
        bounds = {}
        action = {}

        bounds[:x] = richaction.x
        bounds[:y] = richaction.y
        bounds[:width] = richaction.width
        bounds[:height] = richaction.height
        action[:type] = richaction.richaction_type
        case richaction.richaction_type
        when "message"
          action[:text] = richaction.text
        when "uri"
          action[:uri] = richaction.uri
        when "postback"
          action[:text] = richaction.text
          action[:data] = richaction.data
        end
        area[:bounds] = bounds
        area[:action] = action
        areas.push(area)
      end
      channel_id = current_user.target_channel
      channel = Channel.find_by(channel_id: channel_id)
      secret = channel.channel_secret
      token = channel.channel_token
      client = make_client(channel_id,secret,token)
      rich_menu = {
        size: {
          width: width,
          height: height
        },
        selected: selected,
        name: rich_name,
        chatBarText: chat_bar_text,
        areas: areas
      }
      rich_menu_result = client.create_rich_menu(rich_menu)
      body = rich_menu_result.read_body
      parsed_body = JSON.parse(body)
      richmenu_id = parsed_body["richMenuId"]
      @richmenu.update(richmenu_id: richmenu_id)

      client.create_rich_menu_image(richmenu_id,image)
    else
      render json: @richmenu.errors, status: :unprocessable_entity
    end
  end

  def set_default_richmenu
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    secret = channel.channel_secret
    token = channel.channel_token
    client = make_client(channel_id,secret,token)
    richmenu_id = params[:richmenu_id]
    result = client.set_default_rich_menu(richmenu_id)
    if ((result.to_s.include?"Bad")||(result.to_s.include?"NotFound"))
      render json: "BadRequest", status: :ok
    else
      rich_menus = Richmenu.where.not(richmenu_id: richmenu_id)
      rich_menus.each do |rich|
        rich.update(default_richmenu: false)
      end
      richmenu = Richmenu.find_by(richmenu_id: richmenu_id)
      if richmenu.update(default_richmenu: true)
        render json: richmenu, status: :ok
      else
        render json: richmenu.errors, status: :unprocessable_entity
      end
    end
  end

  def unset_default_richmenu
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    secret = channel.channel_secret
    token = channel.channel_token
    client = make_client(channel_id,secret,token)
    richmenu_id = params[:richmenu_id]
    client.unset_default_rich_menu
    richmenu = Richmenu.find_by(richmenu_id: richmenu_id)
    if richmenu.update(default_richmenu: false)
      render json: richmenu, status: :ok
    else
      render json: richmenu.errors, status: :unprocessable_entity
    end
  end

  def delete_richmenu
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    secret = channel.channel_secret
    token = channel.channel_token
    client = make_client(channel_id,secret,token)
    richmenu_id = params[:richmenu_id]
    client.delete_rich_menu(richmenu_id)

    richmenu = Richmenu.find_by(richmenu_id: richmenu_id)
    richmenu.destroy
  end

  def load_all_richmenus
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    secret = channel.channel_secret
    token = channel.channel_token
    client = make_client(channel_id,secret,token)
    response = client.get_rich_menus
    default = client.get_default_rich_menu
    default = JSON.parse(default.read_body)
    default_id = default["richMenuId"]
    body = response.read_body
    parsed_body = JSON.parse(body)
    parsed_body["richmenus"].each do |richmenu|
      richmenu_id = richmenu["richMenuId"]
      @richmenu = Richmenu.find_by(richmenu_id: richmenu_id)
      if !@richmenu.present?
        rich_action_ids = []
        richmenu["areas"].each do |rich_action|
          x = rich_action["bounds"]["x"]
          y = rich_action["bounds"]["y"]
          width = rich_action["bounds"]["width"]
          height = rich_action["bounds"]["height"]
          richaction_type = rich_action["action"]["type"]
          text = rich_action["action"]["text"]
          uri = rich_action["action"]["uri"]
          data = rich_action["action"]["data"]
          @richaction = Richaction.new({
            x: x, y: y, width: width, height: height, richaction_type: richaction_type, text: text, uri: uri, data: data
          })
          @richaction.save
          rich_action_ids.push(@richaction.id)
        end
        richmenu_id = richmenu["richMenuId"]
        rich_name = richmenu["name"]
        contents = rich_action_ids.join(",")
        width = richmenu["size"]["width"]
        height = richmenu["size"]["height"]
        chat_bar_text = richmenu["chatBarText"]
        selected = richmenu["selected"]
        image = client.get_rich_menu_image(richmenu_id)
        if richmenu_id == default_id
          default_richmenu = true
        else
          default_richmenu = false
        end
        image_check = image.to_s
        if image_check.include? "NotFound"
          image = nil
        end
        @rich_menu = Richmenu.new({
          name: rich_name, contents: contents, width: width, height: height, chat_bar_text: chat_bar_text, selected: selected, richmenu_id: richmenu_id, channel_id: channel_id, default_richmenu: default_richmenu
        })
        @rich_menu.save
      end
    end
  end

  def update_follows
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    channel_name = channel.channel_name
    secret = channel.channel_secret
    token = channel.channel_token
    @client = make_client(channel_id,secret,token)
    follow = Follow.where(channel_id: channel_id).order("date DESC").first

    base_number = 0
    if follow.present?
      today = DateTime.now.beginning_of_day
      date = follow.date.to_datetime
      base_number = (today - date).to_i
      if base_number > 60
        base_number = 60
      end
    else
      base_number = 60
    end
    if base_number > 1
      for i in 1..(base_number-1) do
        datetime = DateTime.now
        datetime = datetime.beginning_of_day
        datetime = datetime - i
        temp = datetime.strftime("%Y%m%d")
        follows = @client.get_number_of_followers(temp)
        body = follows.body
        parsed_body = JSON.parse(body)
        followers = parsed_body["followers"]
        targetedReaches = parsed_body["targetedReaches"]
        blocks = parsed_body["blocks"]
        @follow = Follow.new({channel_name: channel_name, follower: followers, targetedReaches: targetedReaches, blocks: blocks, date: datetime, channel_id: channel_id})
        if @follow.save
          sleep DEFAULT_SLEEP
        else
          render json: @follow.errors, status: :unprocessable_entity
        end
      end
    end
    render json: follow, status: :ok
  end

  private

  def message_params
    if params[:message].present?
      @channel = Channel.find_by(channel_id: current_user.target_channel)
      params[:message][:channel_destination] = @channel.channel_destination
      params.require(:message).permit(
        :id, :sender, :receiver, :contents ,:message_type, :message_id, :sticker_id, :package_id, :fr_account, :channel_destination, :reply_token, :check_status)
    else
      @channel = Channel.find_by(channel_id: current_user.target_channel)
      params[:channel_destination] = @channel.channel_destination
      params.permit(
        :id, :sender, :receiver, :contents ,:message_type, :message_id, :sticker_id, :package_id, :fr_account, :channel_destination, :reply_token, :check_status
        )
    end
  end

  def richmenu_params
    params[:channel_id] = current_user.target_channel
    params.permit(
      :name, :contents, :image, :width, :height, :selected, :chat_bar_text, :richmenu_id, :channel_id
      )
  end
end
