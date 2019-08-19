class Api::MessagesController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  THUMBNAIL_URL = 'https://www.freepngimg.com/thumb/mario/20723-2-mario-image.png'
  HORIZONTAL_THUMBNAIL_URL = 'https://via.placeholder.com/1024x768'
  QUICK_REPLY_ICON_URL = 'https://via.placeholder.com/64x64'

  # set :app_base_url, ENV['APP_BASE_URL']
  protect_from_forgery with: :null_session

  def index
    group = current_user.group
    @group = Group.select("group_id").where(group: group)
    @messages = Message.where(group_id: @group).order("created_at DESC")
  end

  def create
    @message = Message.new(message_params)
    @notify = Notify.new
    if @message.save
      render :show, status: :created
      @notify.send(@message)
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def show
    @message = Message.find(params[:id])
    render :show, status: :ok
  end

  def show_with_id
    @message = Message.order("created_at DESC").find_by(fr_account: params[:fr_account])
    render :show, status: :ok
  end

  def index_with_id
    group = current_user.group
    @group = Group.select("group_id").where(group: group)
    @messages = Message.where(fr_account:params[:fr_account], group_id: @group).order("created_at DESC")
    render :index, status: :ok
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
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

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      #halt 400, {'Content-Type' => 'text/plain'}, 'Bad Request'
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        handle_message(event)

      when Line::Bot::Event::Follow
        profile = client.get_profile(event['source']['userId'])
        profile = JSON.parse(profile.read_body)

        reply_text(event, "[FullouT]\n友達登録いただき、ありがとうございます、#{profile['displayName']}様！")
        fr_account = event['source']['userId']
        friend = Friend.where(fr_account: fr_account)

        if friend.blank?
          add_friend(fr_account,profile['displayName'],profile['pictureUrl'],profile['statusMessage'])
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
        message = "[POSTBACK]\n#{event['postback']['data']} (#{JSON.generate(event['postback']['params'])})"
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

      when '이죽', 'naruto', 'FullouT'
        reply_text(event, "sasuke")

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
        time = Time.new
        time = time.yesterday
        date = time.strftime("%Y%m%d")

        userInfo = client.get_number_of_followers(date)
        userInfo = JSON.parse(userInfo.read_body)
        puts "userInfo"
        puts userInfo



        if event['source']['type'] == 'user'
          profile = client.get_profile(event['source']['userId'])
          profile = JSON.parse(profile.read_body)
          group_id = @parsed_body['destination']
          reply_text(event, [
            "Display name\n#{profile['displayName']}",
            "[FullouT]\n#{event.message['text']}"
          ])

          textFromUser(profile['displayName'],event.message['text'], event.message['id'], profile['userId'], group_id)
          #client.get_quota
          update_friend_info(profile['userId'],profile['displayName'],profile['pictureUrl'],profile['statusMessage'],group_id)
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
    messages.push(
      type: 'sticker',
      packageId: event.message['packageId'],
      stickerId: event.message['stickerId']
      )
    group_id = @parsed_body['destination']
    stickerFromUser(profile['displayName'], event.message['stickerId'], event.message['stickerId'], event.message['packageId'], profile['userId'],group_id)
    update_friend_info(profile['userId'],profile['displayName'],profile['pictureUrl'],profile['statusMessage'],group_id)
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

  def textFromUser(sender,contents,message_id,fr_account,group_id)
    @message = Message.new({
      sender: sender,
      receiver: 'FullouT',
      contents: contents,
      message_type: 'text',
      message_id: message_id,
      fr_account: fr_account,
      group_id: group_id
    })
    if @message.save
      get_number_of_monthly_message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def stickerFromUser(sender,message_id,sticker_id,package_id,fr_account,group_id)
    @message = Message.new({
      sender: sender,
      receiver: 'FullouT',
      contents: "https://cdn.lineml.jp/api/media/sticker/#{package_id}_#{sticker_id}",
      message_type: 'sticker',
      message_id: message_id,
      sticker_id: sticker_id,
      package_id: package_id,
      fr_account: fr_account,
      group_id: group_id
    })
    if @message.save
      render :show, status: :created
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
    if friend.update(block: 1)
      render html: '/api/friends', status: :ok
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def unblock(fr_account)
    friend = Friend.where(fr_account: fr_account)
    if friend.update(block: 0)
      render html: '/api/friends', status: :ok
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def update_friend_info(fr_account,fr_name,profile_pic,profile_msg,group_id)
    @friend = Friend.find_by(fr_account: fr_account)
    time = Time.new
    puts time
    if @friend.update(
      fr_name: fr_name, profile_pic: profile_pic, profile_msg: profile_msg,group_id: group_id,
      last_message_time: time
      )
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

  def get_number_of_monthly_message
    now = Time.new
    startTime = now.beginning_of_month
    endTime = now.end_of_month
    group = get_current_user_group
    @messages = Message.where(created_at: startTime..endTime, receiver: group)

    render :index, status: :ok
  end

  def get_current_user_group
    return current_user.group
  end

  def get_number_of_weekly_message
    now = Time.new
    startTime = now.beginning_of_week
    endTime = now.end_of_week
    group = get_current_user_group
    @messages = Message.where(created_at: startTime..endTime, receiver: group)

    render :index,  status: :ok
  end

  def get_number_of_daily_message
    now = Time.new
    startTime = now.beginning_of_day
    endTime = now.end_of_day
    group = get_current_user_group
    @messages = Message.where(created_at: startTime..endTime, receiver: group)

    render :index,  status: :ok
  end

  def get_number_of_seven_days
    now = Time.new
    startTime = now.days_ago(6)
    group = get_current_user_group
    @messages = Message.where(created_at: startTime..now, receiver: group)

    render :index,  status: :ok
  end

  private

  def message_params
    params.fetch(:message, {}).permit(
      :id, :sender, :receiver, :contents, :created_at, :updated_at, :message_type, :message_id, :sticker_id, :package_id, :fr_account,
      )
  end
end
