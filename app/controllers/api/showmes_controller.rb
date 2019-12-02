class Api::ShowmesController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  THUMBNAIL_URL = 'https://www.disney.co.jp/content/dam/disney/images/sns/studio_mstore_03.jpg'
  THUMBNAIL_URL1 = 'https://www.disney.co.jp/content/disney/jp/deluxe/blog/maximum-guide/live-action-aladdin-subtitle/_jcr_content/par/navi_vertical_child/navi_vertical_child_par/image_only_1500734488/image.img.jpg/1570425883041.jpg'
  LOTTO_URL = 'https://www.japannetbank.co.jp/lottery/images/index_img032.png'
  HORIZONTAL_THUMBNAIL_URL = 'https://via.placeholder.com/1024x768'
  QUICK_REPLY_ICON_URL = 'https://via.placeholder.com/64x64'

  # set :app_base_url, ENV['APP_BASE_URL']
  protect_from_forgery with: :null_session

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_id = ENV["SHOW_ME_ID"]
      config.channel_secret = ENV["SHOW_ME_SECRET"]
      config.channel_token = ENV["SHOW_ME_TOKEN"]
      config.http_options = {
        open_timeout: 5,
        read_timeout: 5,
      }
    end
  end

  def client1
    @client ||= Line::Bot::Client.new do |config|
      config.channel_id = ENV["SHOW_ME_ID"]
      config.channel_secret = ENV["SHOW_ME_SECRET"]
      config.channel_token = ENV["SHOW_ME_TOKEN"]
      config.http_options = {
        open_timeout: 5,
        read_timeout: 5,
      }
    end
  end

  def client2
    @client ||= Line::Bot::Client.new do |config|
      config.channel_id = ENV["FULLOUT_CHANNEL_ID"]
      config.channel_secret = ENV["FULLOUT_CHANNEL_SECRET"]
      config.channel_token = ENV["FULLOUT_CHANNEL_TOKEN"]
      config.http_options = {
        open_timeout: 5,
        read_timeout: 5,
      }
    end
  end

  def reply_text(event, texts)
    texts = [texts] if texts.is_a?(String)
    client.reply_message(
      event['replyToken'],
      texts.map { |text| {type: 'text', text: text} }
      )
  end

  def reply_content(event, messages)
    res = client.reply_message(
      event['replyToken'],
      messages
      )
    logger.warn res.read_body unless Net::HTTPOK === res
    render json: messages, status: :ok
  end

  def callback
    body = request.body.read
    @parsed_body = JSON.parse(body)
    @group_id = @parsed_body['destination']
    group = Group.find_by(group_id: @group_id)
    @group = group.attributes["group"]
    case @group
    when "ShowMeTheMoney"
      client = client1
    when "FullouT"
      client = client2
    end
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      halt 400, {'Content-Type' => 'text/plain'}, 'Bad Request'
    end
    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        handle_message(event)

      when Line::Bot::Event::Follow
        profile = client.get_profile(event['source']['userId'])
        profile = JSON.parse(profile.read_body)

        fr_account = event['source']['userId']

        friend = Friend.find_by(fr_account: fr_account)
        if friend.blank?
          friend = add_friend(fr_account,profile['displayName'],profile['pictureUrl'],profile['statusMessage'],@group_id)
        else
          unblock(fr_account)
        end
        option = Option.find_by(user_group: @group, option_type: 'welcomeReply')
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
          message = "#{event['postback']['data']}"
          fr_account = event['source']['userId']
          send_lottery_number(fr_account,message)
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
        bubble.footer_button, bubble.footer_uri, bubble.footer_message)
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

  def footer_converter(footer,gravity,align,size,bold,color,background,type,button,uri,message)
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

  def send_lottery_number(fr_account,num)
    case num
    when "7"
      text = (1..37).to_a.sample(7).to_s
      message = {
        type: 'text',
        text: "ロト７ナンバー\n"+text
      }
    when "6"
      text = (1..43).to_a.sample(6).to_s
      message = {
        type: 'text',
        text: "ロト６ナンバー\n"+text
      }
    when "5"
      text = (1..31).to_a.sample(5).to_s
      message = {
        type: 'text',
        text: "ミニロトナンバー\n"+text
      }
    end
    client.push_message(fr_account, message)
  end

  def handle_message(event)
    check_user(event)
    case event.type
    when Line::Bot::Event::MessageType::Image
      message_id = event.message['id']
      response = client.get_message_content(message_id)
      tf = Tempfile.open("content")
      puts tf
      tf.write(response.body)
      reply_text(event, "[MessageType::IMAGE]\nid:#{message_id}\nreceived #{tf.size} bytes data")
    when Line::Bot::Event::MessageType::Video
      message_id = event.message['id']
      response = client.get_message_content(message_id)
      tf = Tempfile.open("content")
      tf.write(response.body)
      reply_text(event, "[MessageType::VIDEO]\nid:#{message_id}\nreceived #{tf.size} bytes data")
    when Line::Bot::Event::MessageType::Audio
      message_id = event.message['id']
      response = client.get_message_content(message_id)
      tf = Tempfile.open("content")
      tf.write(response.body)
      reply_text(event, "[MessageType::AUDIO]\nid:#{message_id}\nreceived #{tf.size} bytes data")
    when Line::Bot::Event::MessageType::File
      message_id = event.message['id']
      response = client.get_message_content(message_id)
      tf = Tempfile.open("content")
      tf.write(response.body)
      reply_text(event, "[MessageType::FILE]\nid:#{message_id}\nfileName:#{event.message['fileName']}\nfileSize:#{event.message['fileSize']}\nreceived #{tf.size} bytes data")
    when Line::Bot::Event::MessageType::Sticker
      handle_sticker(event)
    when Line::Bot::Event::MessageType::Location
      handle_location(event)
    when Line::Bot::Event::MessageType::Text
      case event.message['text']
      when 'Naruto', 'ShowMeTheMoney'
        reply_text(event, 0x100078.chr("UTF-8"))

      when '버튼'
        reply_content(event, {
          type: 'template',
          altText: 'Buttons alt text',
          template: {
            type: 'buttons',
            thumbnailImageUrl: THUMBNAIL_URL,
            title: 'My button sample',
            text: 'Hello, my button',
            actions: [
              { label: 'Go to line.me', type: 'uri', uri: 'https://line.me', altUri: {desktop: 'https://line.me#desktop'} },
              { label: 'Send postback', type: 'postback', data: 'hello world' },
              { label: 'Send postback2', type: 'postback', data: 'hello world', text: 'hello world' },
              { label: 'Send message', type: 'message', text: 'This is message' }
            ]
          }
        })

      when "いまなんじ"
        reply_content(event, {
          type: 'template',
          altText: 'Buttons alt text',
          template: {
            type: 'buttons',
            thumbnailImageUrl: LOTTO_URL,
            title: '宝くじ',
            text: '自分の宝くじを選択してください。',
            actions: [
              { label: 'ロト7', type: 'postback', data: 7, text: 'ロト7'},
              { label: 'ロト6', type: 'postback', data: 6, text: 'ロト6' },
              { label: 'ミニロト', type: 'postback', data: 5, text: 'ミニロト' },
            ]
          }
        })

      when 'flex'
        reply_content(event, {
          type: "flex",
          altText: "this is a flex message",
          contents: {
            type: "bubble",
            header: {
              type: "box",
              layout: "vertical",
              contents: [
                {
                  type: "text",
                  text: "Header text",
                  size: "md",
                  weight: "regular",
                  align: "center",
                  position: "relative",
                  offsetBottom: "-15px",
                  color: "#111111",
                  wrap: true
                }
              ],
              backgroundColor: "#dc3545"
            },
            hero: {
              type: "image",
              url: THUMBNAIL_URL,
              size: "4xl",
              aspectRatio: "1:1",
              align: "start",
              backgroundColor: "#00b900"
            },
            body: {
              type: "box",
              layout: "vertical",
              contents: [
                {
                  type: "text",
                  text: "Body text\nBody text\nBody text",
                  position: "relative",
                  offsetBottom: "-10px",
                  align: "center",
                  wrap: true
                }
              ],
              backgroundColor: "#CC0000"
            },
            footer: {
              type: "box",
              layout: "horizontal",
              contents: [
                {
                  type: "text",
                  text: "footer",
                  position: "relative",
                  offsetBottom: "0px",
                  align: "center",
                  size: "xxl",
                  wrap: true
                }
              ]
            }
          }
        })

      when 'bye'
        case event['source']['type']
        when 'user'
          reply_text(event, "[BYE]\nBot can't leave from 1:1 chat")
        when 'group'
          reply_text(event, "[BYE]\nLeaving group")
          client.leave_group(event['source']['groupId'])
        when 'room'
          reply_text(event, "[BYE]\nLeaving room")
          client.leave_room(event['source']['roomId'])
        end

      else
        if event['source']['type'] == 'user'
          profile = client.get_profile(event['source']['userId'])
          profile = JSON.parse(profile.read_body)
          group_id = @group_id
          reply_token = event['replyToken']

          @message = Message.new({sender: profile['displayName'], receiver: @group, contents: event.message['text'], message_type: 'text', message_id: event.message['id'], sticker_id: nil, package_id: nil, fr_account: profile['userId'], group_id: group_id, reply_token: reply_token, check_status: 'unchecked'})
          message = Message.new({sender: @group, receiver: profile['displayName'], message_id: event.message['id'],fr_account: profile['userId'], group_id: group_id, reply_token: reply_token, check_status: 'answered'})

          save_message(@message)
          update_friend_info(profile['userId'],profile['displayName'],profile['pictureUrl'],profile['statusMessage'],group_id,@message.contents)
          event.message['text'] = unicodeConverter(event.message['text'])
          auto_reply = option_checker(event,message)
          # reply_text(event, "ありがとうございます。")
        else
          reply_text(event, "Bot can't use profile API without user ID")
        end
      end
    else
      logger.info "Unknown message type: #{event.type}"
      reply_text(event, "[UNKNOWN]\n#{event.type}")
    end
  end

  def check_user(event)
    fr_account = event['source']['userId']
    group_id = @group_id
    friend = Friend.find_by(fr_account: fr_account)
    if friend.present?
      puts "user check success"
    else
      response = client.get_profile(fr_account)
      case response
      when Net::HTTPSuccess then
        contact = JSON.parse(response.body)
        fr_name = contact['displayName']
        profile_pic = contact['pictureUrl']
        profile_msg = contact['statusMessage']
        add_friend(fr_account,fr_name,profile_pic,profile_msg,group_id)
      else
        p "#{response.code} #{response.body}"
      end
    end
  end

  def handle_sticker(event)
    # msgapi_available = event.message['packageId'].to_i <= 4
    # messages = []
    profile = client.get_profile(event['source']['userId'])
    profile = JSON.parse(profile.read_body)
    messages = [{
      type: 'text',
      text: "[STICKER]\npackageId: #{event.message['packageId']}\nstickerId: #{event.message['stickerId']}"
    }]

    # if msgapi_available
    # messages.push(
    #   type: 'sticker',
    #   packageId: event.message['packageId'],
    #   stickerId: event.message['stickerId']
    #   )
    # end
    group_id = @group_id
    reply_token = event['replyToken']
    sticker_id = event.message['stickerId']
    package_id = event.message['packageId']
    @message = Message.new({sender: profile['displayName'], receiver: @group, contents: "#{package_id}_#{sticker_id}", message_type: 'stamp', message_id: event.message['id'], sticker_id: sticker_id, package_id: package_id, fr_account: profile['userId'], group_id: group_id, reply_token: reply_token, check_status: 'unchecked'})
    save_message(@message)

    update_friend_info(profile['userId'],profile['displayName'],profile['pictureUrl'],profile['statusMessage'],group_id,@message.contents)
    # end
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

  def save_message(message)
    if message.save
      # render :index, status: :ok
      puts "message saved"
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def add_friend(fr_account,fr_name,profile_pic,profile_msg,group_id)
    @friend = Friend.new({fr_account: fr_account, fr_name: fr_name, profile_pic: profile_pic, profile_msg: profile_msg, group_id: group_id})
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

  def update_friend_info(fr_account,fr_name,profile_pic,profile_msg,group_id,contents)
    @group = Group.find_by(group_id: group_id)
    @group = @group.group
    @friend = Friend.find_by(fr_account: fr_account)
    time = Time.new
    if @friend.update(fr_name: fr_name, profile_pic: profile_pic, profile_msg: profile_msg,group_id: group_id,last_message_time: time,last_message: contents)
      update_message_profile(fr_account,fr_name,@group)
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def update_message_profile(fr_account,fr_name,group)
    @messages = Message.where(fr_account: fr_account, receiver: group)
    if @messages.update(sender: fr_name)
      # puts "profile updated"
      messages = Message.where(fr_account: fr_account, sender: group)
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
    sender = current_user.group
    receiver = 'ALL'
    @group = Group.find_by(group: sender)
    group_id = @group.attributes["group_id"]

    @notify = Notify.new({sender: sender, receiver: receiver, contents: contents, notify_type: notify_type, group_id: group_id, image: image})

    if @notify.notify_type == "text"
      broadcast_text(sender,contents)
    elsif @notify.notify_type == "stamp"
      broadcast_stamp(sender,contents)
    elsif @notify.notify_type == "image"
      broadcast_image(sender,@notify.image)
    elsif @notify.notify_type == "text+image"
      broadcast_text(sender,contents)
      broadcast_image(sender,@notify.image)
    elsif @notify.notify_type == "map"
      address_array = map_converter(contents)
      broadcast_map(sender,address_array)
      @notify.contents = address_array[0]
    elsif @notify.notify_type == "carousel"
      broadcast_carousel(sender,contents)
    end
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

  def broadcast_text(sender,contents)
    contents = contents_converter(contents)
    message = {
      "type": "text",
      "text": "["+current_user.group+"]\n"+contents
    }
    client = client_selecter(sender)
    client.broadcast(message)
  end

  def client_selecter(group)
    client = nil
    case group
    when "ShowMeTheMoney"
      client = client1
    when "FullouT"
      client = client2
    end
    return client
  end

  def broadcast_stamp(sender,contents)
    message = {
      type: 'sticker',
      packageId: 1,
      stickerId: contents[2..contents.length].to_i
    }
    client = client_selecter(sender)
    client.broadcast(message)
  end

  def broadcast_image(sender,url)
    address = url.to_s
    message = {
      type: "image",
      originalContentUrl: address,
      previewImageUrl: address
    }
    client = client_selecter(sender)
    client.broadcast(message)
  end

  def broadcast_map(sender,arr)
    mapArray = arr[1].split(',')
    message = {
      "type": "location",
      "title": "位置情報",
      "address": arr[0],
      "latitude": mapArray[0],
      "longitude": mapArray[1]
    };
    client = client_selecter(sender)
    client.broadcast(message)
  end

  def broadcast_carousel(sender,contents)
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
    client = client_selecter(sender)
    client.broadcast(message)
  end

  def unicodeConverter(text)
    if text.include?"(waving hand)"
      text = text.gsub("(waving hand)",0x100031.chr("UTF-8"))
    elsif text.include?"(love)"
      text = text.gsub("(love)",0x100078.chr("UTF-8"))
    elsif text.include?"(hahaha)"
      text = text.gsub("(hahaha)",0x100079.chr("UTF-8"))
    elsif text.include?"(please!)"
      text = text.gsub("(please!)",0x10007A.chr("UTF-8"))
    elsif text.include?"(shocked)"
      text = text.gsub("(shocked)",0x10007B.chr("UTF-8"))
    elsif text.include?"(sad)"
      text = text.gsub("(sad)",0x10007C.chr("UTF-8"))
    elsif text.include?"(oh no!)"
      text = text.gsub("(oh no!)",0x10007D.chr("UTF-8"))
    elsif text.include?"(super angry)"
      text = text.gsub("(super angry)",0x10007E.chr("UTF-8"))
    elsif text.include?"(hee)"
      text = text.gsub("(hee)",0x10008C.chr("UTF-8"))
    elsif text.include?"(moon grin)"
      text = text.gsub("(moon grin)",0x10008D.chr("UTF-8"))
    elsif text.include?"(oops)"
      text = text.gsub("(oops)",0x10008E.chr("UTF-8"))
    elsif text.include?"(moon wink)"
      text = text.gsub("(moon wink)",0x10008F.chr("UTF-8"))
    elsif text.include?"(content)"
      text = text.gsub("(content)",0x100090.chr("UTF-8"))
    elsif text.include?"(gasp)"
      text = text.gsub("(gasp)",0x100091.chr("UTF-8"))
    elsif text.include?"(blue)"
      text = text.gsub("(blue)",0x100092.chr("UTF-8"))
    elsif text.include?"(nom nom)"
      text = text.gsub("(nom nom)",0x100093.chr("UTF-8"))
    elsif text.include?"(ah...)"
      text = text.gsub("(ah...)",0x100094.chr("UTF-8"))
    elsif text.include?"(at last!)"
      text = text.gsub("(at last!)",0x100095.chr("UTF-8"))
    elsif text.include?"(haha)"
      text = text.gsub("(haha)",0x10007F.chr("UTF-8"))
    elsif text.include?"(sparkling eyes)"
      text = text.gsub("(sparkling eyes)",0x100080.chr("UTF-8"))
    elsif text.include?"(kiss me)"
      text = text.gsub("(kiss me)",0x100081.chr("UTF-8"))
    elsif text.include?"(tongue out)"
      text = text.gsub("(tongue out)",0x100082.chr("UTF-8"))
    elsif text.include?"(frozen)"
      text = text.gsub("(frozen)",0x100083.chr("UTF-8"))
    elsif text.include?"(kony kiss)"
      text = text.gsub("(kony kiss)",0x100096.chr("UTF-8"))
    elsif text.include?"(hmph)"
      text = text.gsub("(hmph)",0x100097.chr("UTF-8"))
    elsif text.include?"(brr)"
      text = text.gsub("(brr)",0x100098.chr("UTF-8"))
    elsif text.include?"(half dead)"
      text = text.gsub("(half dead)",0x100099.chr("UTF-8"))
    elsif text.include?"(sharp)"
      text = text.gsub("(sharp)",0x10009A.chr("UTF-8"))
    elsif text.include?"(panic)"
      text = text.gsub("(panic)",0x10009B.chr("UTF-8"))
    elsif text.include?"(doze off)"
      text = text.gsub("(doze off)",0x10009C.chr("UTF-8"))
    elsif text.include?"(aww)"
      text = text.gsub("(aww)",0x10009D.chr("UTF-8"))
    elsif text.include?"(argh!)"
      text = text.gsub("(argh!)",0x10009E.chr("UTF-8"))
    elsif text.include?"(brown)"
      text = text.gsub("(brown)",0x100084.chr("UTF-8"))
    elsif text.include?"(eh?!)"
      text = text.gsub("(eh?!)",0x100085.chr("UTF-8"))
    elsif text.include?"(goodnight)"
      text = text.gsub("(goodnight)",0x100086.chr("UTF-8"))
    elsif text.include?"(stressed)"
      text = text.gsub("(stressed)",0x100087.chr("UTF-8"))
    elsif text.include?"(worn out)"
      text = text.gsub("(worn out)",0x100088.chr("UTF-8"))
    elsif text.include?"(what?!)"
      text = text.gsub("(what?!)",0x100089.chr("UTF-8"))
    elsif text.include?"(james wink)"
      text = text.gsub("(james wink)",0x10008A.chr("UTF-8"))
    elsif text.include?"(attracted)"
      text = text.gsub("(attracted)",0x10008B.chr("UTF-8"))
    elsif text.include?"(who, me?)"
      text = text.gsub("(who, me?)",0x10009F.chr("UTF-8"))
    elsif text.include?"(happy)"
      text = text.gsub("(happy)",0x100001.chr("UTF-8"))
    elsif text.include?"(smile)"
      text = text.gsub("(smile)",0x100002.chr("UTF-8"))
    elsif text.include?"(laugh)"
      text = text.gsub("(laugh)",0x100003.chr("UTF-8"))
    elsif text.include?"(blush)"
      text = text.gsub("(blush)",0x100004.chr("UTF-8"))
    elsif text.include?"(wink)"
      text = text.gsub("(wink)",0x100005.chr("UTF-8"))
    elsif text.include?"(glad)"
      text = text.gsub("(glad)",0x100006.chr("UTF-8"))
    elsif text.include?"(glow kiss)"
      text = text.gsub("(glow kiss)",0x100007.chr("UTF-8"))
    elsif text.include?"(kiss)"
      text = text.gsub("(kiss)",0x100008.chr("UTF-8"))
    elsif text.include?"(baffled)"
      text = text.gsub("(baffled)",0x100009.chr("UTF-8"))
    elsif text.include?"(relief)"
      text = text.gsub("(relief)",0x10000A.chr("UTF-8"))
    elsif text.include?"(grin)"
      text = text.gsub("(grin)",0x10000B.chr("UTF-8"))
    elsif text.include?"(kidding)"
      text = text.gsub("(kidding)",0x10000C.chr("UTF-8"))
    elsif text.include?"(funny)"
      text = text.gsub("(funny)",0x10000D.chr("UTF-8"))
    elsif text.include?"(unamused)"
      text = text.gsub("(unamused)",0x10000E.chr("UTF-8"))
    elsif text.include?"(smirk)"
      text = text.gsub("(smirk)",0x10000F.chr("UTF-8"))
    elsif text.include?"(bittersmile)"
      text = text.gsub("(bittersmile)",0x100010.chr("UTF-8"))
    elsif text.include?"(hm)"
      text = text.gsub("(hm)",0x100011.chr("UTF-8"))
    elsif text.include?"(disappointed)"
      text = text.gsub("(disappointed)",0x100012.chr("UTF-8"))
    elsif text.include?"(unbearable)"
      text = text.gsub("(unbearable)",0x100013.chr("UTF-8"))
    elsif text.include?"(coldsweat)"
      text = text.gsub("(coldsweat)",0x100014.chr("UTF-8"))
    elsif text.include?"(exasperated)"
      text = text.gsub("(exasperated)",0x100015.chr("UTF-8"))
    elsif text.include?"(anguished)"
      text = text.gsub("(anguished)",0x100016.chr("UTF-8"))
    elsif text.include?"(tired)"
      text = text.gsub("(tired)",0x100017.chr("UTF-8"))
    elsif text.include?"(tear)"
      text = text.gsub("(tear)",0x100018.chr("UTF-8"))
    elsif text.include?"(crying)"
      text = text.gsub("(crying)",0x100019.chr("UTF-8"))
    elsif text.include?"(tearsofjoy)"
      text = text.gsub("(tearsofjoy)",0x10001A.chr("UTF-8"))
    elsif text.include?"(astonished)"
      text = text.gsub("(astonished)",0x10001B.chr("UTF-8"))
    elsif text.include?"(scream)"
      text = text.gsub("(scream)",0x10001C.chr("UTF-8"))
    elsif text.include?"(pouting)"
      text = text.gsub("(pouting)",0x10001D.chr("UTF-8"))
    elsif text.include?"(angry)"
      text = text.gsub("(angry)",0x10001E.chr("UTF-8"))
    elsif text.include?"(dozing)"
      text = text.gsub("(dozing)",0x10001F.chr("UTF-8"))
    elsif text.include?"(mask)"
      text = text.gsub("(mask)",0x100020.chr("UTF-8"))
    elsif text.include?"(dazed)"
      text = text.gsub("(dazed)",0x100021.chr("UTF-8"))
    elsif text.include?"(catface)"
      text = text.gsub("(catface)",0x100022.chr("UTF-8"))
    elsif text.include?"(yummy)"
      text = text.gsub("(yummy)",0x100023.chr("UTF-8"))
    elsif text.include?"(pig)"
      text = text.gsub("(pig)",0x10005D.chr("UTF-8"))
    elsif text.include?"(cat)"
      text = text.gsub("(cat)",0x10005F.chr("UTF-8"))
    elsif text.include?"(dog)"
      text = text.gsub("(dog)",0x10005E.chr("UTF-8"))
    elsif text.include?"(ghost)"
      text = text.gsub("(ghost)",0x1000A0.chr("UTF-8"))
    elsif text.include?"(jack o'lantern)"
      text = text.gsub("(jack o'lantern)",0x1000A1.chr("UTF-8"))
    elsif text.include?"(devil)"
      text = text.gsub("(devil)",0x100024.chr("UTF-8"))
    elsif text.include?"(skull and crossbones)"
      text = text.gsub("(skull and crossbones)",0x1000A2.chr("UTF-8"))
    elsif text.include?"(poo)"
      text = text.gsub("(poo)",0x1000A3.chr("UTF-8"))
    elsif text.include?"(fire)"
      text = text.gsub("(fire)",0x1000A4.chr("UTF-8"))
    elsif text.include?"(yes)"
      text = text.gsub("(yes)",0x1000A5.chr("UTF-8"))
    elsif text.include?"(no)"
      text = text.gsub("(no)",0x1000A6.chr("UTF-8"))
    elsif text.include?"(toilet)"
      text = text.gsub("(toilet)",0x1000A7.chr("UTF-8"))
    elsif text.include?"(surprise)"
      text = text.gsub("(surprise)",0x100027.chr("UTF-8"))
    elsif text.include?"(sweat)"
      text = text.gsub("(sweat)",0x100029.chr("UTF-8"))
    elsif text.include?"(dash)"
      text = text.gsub("(dash)",0x10002A.chr("UTF-8"))
    elsif text.include?"(zzz)"
      text = text.gsub("(zzz)",0x10002B.chr("UTF-8"))
    elsif text.include?"(libs)"
      text = text.gsub("(libs)",0x10002C.chr("UTF-8"))
    elsif text.include?"(sparkle)"
      text = text.gsub("(sparkle)",0x10002D.chr("UTF-8"))
    elsif text.include?"(eyes)"
      text = text.gsub("(eyes)",0x10002E.chr("UTF-8"))
    elsif text.include?"(ear)"
      text = text.gsub("(ear)",0x10002F.chr("UTF-8"))
    elsif text.include?"(lightning)"
      text = text.gsub("(lightning)",0x10003A.chr("UTF-8"))
    elsif text.include?"(moon)"
      text = text.gsub("(moon)",0x1000A8.chr("UTF-8"))
    elsif text.include?"(sun)"
      text = text.gsub("(sun)",0x1000A9.chr("UTF-8"))
    elsif text.include?"(rain)"
      text = text.gsub("(rain)",0x1000AA.chr("UTF-8"))
    elsif text.include?"(snow)"
      text = text.gsub("(snow)",0x1000AB.chr("UTF-8"))
    elsif text.include?"(cloud)"
      text = text.gsub("(cloud)",0x1000AC.chr("UTF-8"))
    elsif text.include?"(ok)"
      text = text.gsub("(ok)",0x100033.chr("UTF-8"))
    elsif text.include?"(boo)"
      text = text.gsub("(boo)",0x1000AD.chr("UTF-8"))
    elsif text.include?"(scissors)"
      text = text.gsub("(scissors)",0x100030.chr("UTF-8"))
    elsif text.include?"(paper)"
      text = text.gsub("(paper)",0x100031.chr("UTF-8"))
    elsif text.include?"(rock)"
      text = text.gsub("(rock)",0x100032.chr("UTF-8"))
    elsif text.include?"(clap)"
      text = text.gsub("(clap)",0x1000AE.chr("UTF-8"))
    elsif text.include?"(!!)"
      text = text.gsub("(!!)",0x100035.chr("UTF-8"))
    elsif text.include?"(?)"
      text = text.gsub("(?)",0x100036.chr("UTF-8"))
    elsif text.include?"(music note)"
      text = text.gsub("(music note)",0x100039.chr("UTF-8"))
    elsif text.include?"(heart)"
      text = text.gsub("(heart)",0x100037.chr("UTF-8"))
    elsif text.include?"(brokenheart)"
      text = text.gsub("(brokenheart)",0x100038.chr("UTF-8"))
    elsif text.include?"(1 heart)"
      text = text.gsub("(1 heart)",0x1000AF.chr("UTF-8"))
    elsif text.include?"(3 hearts)"
      text = text.gsub("(3 hearts)",0x1000B0.chr("UTF-8"))
    end
    return text
  end

  def option_checker(event,message)
    @text = event.message['text']
    group = Group.find_by(group_id: @group_id)
    group = group.attributes["group"]

    options = Option.where(user_group: group)
    if options.present?
      options.each do |option|
        if check_target(option,message)
          now = Time.new
          tempArray = option.target_day.split(",")
          if tempArray.include? now.wday.to_s
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
      auto_message = Message.new({sender: message.sender, receiver: message.receiver, message_id: message.message_id+'a', fr_account: message.fr_account, group_id: message.group_id, reply_token: message.reply_token, check_status: message.check_status})
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
    update_msg.update({check_status: 'autoReplied'})

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
      message = Message.new({sender: sender, receiver: receiver, message_id: message.message_id+'a', fr_account: message.fr_account, group_id: message.group_id, reply_token: message.reply_token, check_status: 'answered', image: image})
    else
      message = Message.new({sender: sender, receiver: receiver, message_id: message.message_id+'a', fr_account: message.fr_account, group_id: message.group_id, reply_token: message.reply_token, check_status: 'answered', image: nil})
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
    case message.sender
    when "ShowMeTheMoney"
      client1.push_message(message.fr_account, contents_array)
    when "FullouT"
      client2.push_message(message.fr_account, contents_array)
    end
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

    sender = notify.sender
    contents = notify.contents
    url = notify.image.url
    case notify.notify_type
    when "text"
      broadcast_text(sender,contents)
    when "stamp"
      broadcast_stamp(sender,contents)
    when "image"
      broadcast_image(sender,url)
    when "map"
      address_array = map_converter(contents)
      broadcast_map(sender,address_array)
    end
  end

  private

  def message_params
    if params[:message].present?
      @group = Group.find_by(group: current_user.group)
      params[:message][:group_id] = @group.group_id
      params.require(:message).permit(
        :id, :sender, :receiver, :contents ,:message_type, :message_id, :sticker_id, :package_id, :fr_account, :group_id, :reply_token, :check_status)
    else
      @group = Group.find_by(group: current_user.group)
      params[:group_id] = @group.group_id
      params.permit(
        :id, :sender, :receiver, :contents ,:message_type, :message_id, :sticker_id, :package_id, :fr_account, :group_id, :reply_token, :check_status
        )
    end
  end
end
