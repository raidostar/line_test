class Api::ShowmesController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  THUMBNAIL_URL = 'https://vuejs.org/images/logo.png'
  HORIZONTAL_THUMBNAIL_URL = 'https://via.placeholder.com/1024x768'
  QUICK_REPLY_ICON_URL = 'https://via.placeholder.com/64x64'


  # set :app_base_url, ENV['APP_BASE_URL']
  protect_from_forgery with: :null_session

  def client
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

        reply_text(event, "["+@group+"]\n友達登録いただき、ありがとうございます、#{profile['displayName']}様！")
        fr_account = event['source']['userId']
        friend = Friend.where(fr_account: fr_account)

        if friend.blank?
          add_friend(
            fr_account,profile['displayName'],
            profile['pictureUrl'],profile['statusMessage'],
            @group_id
            )
        else
          unblock(fr_account)
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
        end
        reply_text(event, message)

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

  def handle_message(event)
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

      when 'ボタン'
        time = Time.new
        reply_content(event, {
          type: 'template',
          altText: 'Carousel alt text',
          template: {
            type: 'carousel',
            columns: [
              {
                title: '予約店選択',
                text: '下記のリストで選択してください。',
                actions: [
                  { label: 'heel GINZA【ヒール ギンザ】', type: 'postback', data: 'https://beauty.hotpepper.jp/slnH000243060/?wak=BPSC200408_link_PRsalon1_top' },
                  { label: 'TAYA 丸の内店', type: 'postback', data: 'https://beauty.hotpepper.jp/slnH000052996/?cstt=1' },
                  { label: 'W3school', type: 'postback', data: 'https://www.w3schools.com/js/js_string_methods.asp' }
                ]
              },
              {
                title: '予約時間',
                text: '予約時間を設定してください。',
                actions: [
                  {
                    type: 'datetimepicker',
                    label: "Datetime",
                    data: '予約時間',
                    mode: 'datetime',
                    initial: time.strftime("%Y-%m-%dT%H:%M"),
                    max: '2100-12-31T23:59',
                    min: '1900-01-01T00:00'
                  },
                  {
                    type: 'datetimepicker',
                    label: "Date",
                    data: 'action=sel&only=date',
                    mode: 'date',
                    initial: '2017-06-18',
                    max: '2100-12-31',
                    min: '1900-01-01'
                  },
                  {
                    type: 'datetimepicker',
                    label: "Time",
                    data: 'action=sel&only=time',
                    mode: 'time',
                    initial: '12:15',
                    max: '23:00',
                    min: '10:00'
                  }
                ]
              }
            ]
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
          save_message(@message)
          update_friend_info(profile['userId'],profile['displayName'],profile['pictureUrl'],profile['statusMessage'],group_id,@message.contents)
          event.message['text'] = unicodeConverter(event.message['text'])
          message = Message.new({sender: @group, receiver: profile['displayName'], message_id: event.message['id'],fr_account: profile['userId'], group_id: group_id, reply_token: reply_token, check_status: 'answered'})
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
    @message = Message.new({sender: profile['displayName'], receiver: @group, contents: "https://cdn.lineml.jp/api/media/sticker/#{package_id}_#{sticker_id}", message_type: 'stamp', message_id: event.message['id'], sticker_id: sticker_id, package_id: package_id, fr_account: profile['userId'], group_id: group_id, reply_token: reply_token, check_status: 'unread'})
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
      render :index, status: :ok
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def add_friend(fr_account,fr_name,profile_pic,profile_msg,group_id)
    @friend = Friend.new({fr_account: fr_account, fr_name: fr_name, profile_pic: profile_pic, profile_msg: profile_msg})
    if @friend.save
      puts "save!"
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
    friend = Friend.where(fr_account: fr_account)
    now = Time.new
    if friend.update(block: 0, follow_at: now)
      render html: '/api/friends', status: :ok
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def update_friend_info(fr_account,fr_name,profile_pic,profile_msg,group_id,contents)
    @friend = Friend.find_by(fr_account: fr_account)
    time = Time.new
    puts time
    if @friend.update(fr_name: fr_name, profile_pic: profile_pic, profile_msg: profile_msg,group_id: group_id,last_message_time: time,last_message: contents)
      update_message_profile(fr_account,fr_name)
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def update_message_profile(fr_account,fr_name)
    @messages = Message.where(fr_account: fr_account)
    if @messages.update(sender: fr_name)
      puts "profile updated"
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
      broadcast_text(contents)
    elsif @notify.notify_type == "stamp"
      broadcast_stamp(contents)
    elsif @notify.notify_type == "image"
      broadcast_image(@notify.image)
    elsif @notify.notify_type == "text+image"
      broadcast_text(contents)
      broadcast_image(@notify.image)
    elsif @notify.notify_type == "map"
      address_array = map_converter(contents)
      broadcast_map(address_array)
      @notify.contents = address_array[0]
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

  def broadcast_text(contents)
    contents = contents_converter(contents)
    message = {
      "type": "text",
      "text": "["+current_user.group+"]\n"+contents
    }
    client.broadcast(message)
  end

  def broadcast_stamp(contents)
    message = {
      type: 'sticker',
      packageId: 1,
      stickerId: contents[2..contents.length].to_i
    }
    client.broadcast(message)
  end

  def broadcast_image(url)
    address = url.to_s
    message = {
      type: "image",
      originalContentUrl: address,
      previewImageUrl: address
    }
    client.broadcast(message)
  end

  def broadcast_map(arr)
    mapArray = arr[1].split(',')
    message = {
      "type": "location",
      "title": "位置情報",
      "address": arr[0],
      "latitude": mapArray[0],
      "longitude": mapArray[1]
    };
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

  def send_by_option(event,array,message)
    reply_contents = []
    array.each do |id|
      reaction = Reaction.find(id)
      message = Message.new({sender: message.sender, receiver: message.receiver, message_id: message.message_id+'a', fr_account: message.fr_account, group_id: message.group_id, reply_token: message.reply_token, check_status: message.check_status})
      case reaction.attributes["reaction_type"]
      when "text"
        contents = contents_converter(reaction.attributes["contents"])
        message.contents = contents
        message.message_type = 'text'
        message.save
        contents = {
          type: 'text',
          text: contents
        }
        puts "before enter"
        puts contents
        reply_contents.push(contents)
      when "stamp"
        contents = reaction.attributes["contents"]
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
        reply_contents.push(contents)
      when "image"
        address = reaction.image.url.to_s
        message.contents = address
        message.message_type = 'image'
        message.save
        contents = {
          type: "image",
          originalContentUrl: address,
          previewImageUrl: address
        }
        reply_contents.push(contents)
      when "map"
        contents = reaction.attributes["contents"]
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
        reply_contents.push(contents)
        reply_contents.push(image)
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
      contents = contents.gsub(/&nbsp;/,'')
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
    if message.contents.length < 10
      reply_intro = '【 re: '+message.contents+' 】'
    else
      reply_intro = '【 re: '+message.contents[0..7]+'... 】'
    end
    reply = {'type': 'text','text': reply_intro}
    if image.present?
      message = Message.new({sender: message.receiver, receiver: message.sender, message_id: message.message_id+'a', fr_account: message.fr_account, group_id: message.group_id, reply_token: message.reply_token, check_status: 'answered', image: image})
    else
      message = Message.new({sender: message.receiver, receiver: message.sender, message_id: message.message_id+'a', fr_account: message.fr_account, group_id: message.group_id, reply_token: message.reply_token, check_status: 'answered', image: nil})
    end

    case message_type
    when "text"
      puts "text를 보낸다"
      message.contents = contents
      message.message_type = 'text'
      contents = contents_converter(contents)
      puts "contents"
      puts contents
      contents = {
        'type': 'text',
        'text': reply_intro+"\n"+contents
      }
      contents_array.push(contents)
    when "stamp"
      puts "stamp를 보낸다"
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
      contents_array.push(reply)
      contents_array.push(contents)
    when "image"
      puts "image를 보낸다"
      message.contents = contents
      message.message_type = 'image'
      message.save
      address = message.image.url.to_s
      contents = {
        type: "image",
        originalContentUrl: address,
        previewImageUrl: address
      }
    when "map"
      puts "map를 보낸다"
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
      contents_array.push(reply)
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
