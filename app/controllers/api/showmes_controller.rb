class Api::ShowmesController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  THUMBNAIL_URL = 'https://www.freepngimg.com/thumb/mario/20723-2-mario-image.png'
  HORIZONTAL_THUMBNAIL_URL = 'https://via.placeholder.com/1024x768'
  QUICK_REPLY_ICON_URL = 'https://via.placeholder.com/64x64'

  # set :app_base_url, ENV['APP_BASE_URL']
  protect_from_forgery with: :null_session

  def index
    @messages = Message.all.order("created_at DESC")
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
      config.channel_id = ENV["SHOW_ME_ID"]
      config.channel_secret = ENV["SHOW_ME_SECRET"]
      config.channel_token = ENV["SHOW_ME_TOKEN"]
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
      when 'profile'
        if event['source']['type'] == 'user'
          profile = client.get_profile(event['source']['userId'])
          profile = JSON.parse(profile.read_body)
          reply_text(event, [
            "Display name\n#{profile['displayName']}",
            "Status message\n#{profile['statusMessage']}"
          ])
        else
          reply_text(event, "Bot can't use profile API without user ID")
        end

      when '이죽', 'naruto', 'FullouT'
        reply_text(event, "sasuke")

      when 'buttons'
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

      when 'confirm'
        reply_content(event, {
          type: 'template',
          altText: 'Confirm alt text',
          template: {
            type: 'confirm',
            text: 'Do it?',
            actions: [
              { label: 'Yes', type: 'message', text: 'Yes!' },
              { label: 'No', type: 'message', text: 'No!' },
            ],
          }
        })

      when 'carousel'
        reply_content(event, {
          type: 'template',
          altText: 'Carousel alt text',
          template: {
            type: 'carousel',
            columns: [
              {
                title: 'hoge',
                text: 'fuga',
                actions: [
                  { label: 'Go to line.me', type: 'uri', uri: 'https://line.me', altUri: {desktop: 'https://line.me#desktop'} },
                  { label: 'Send postback', type: 'postback', data: 'hello world' },
                  { label: 'Send message', type: 'message', text: 'This is message' }
                ]
              },
              {
                title: 'Datetime Picker',
                text: 'Please select a date, time or datetime',
                actions: [
                  {
                    type: 'datetimepicker',
                    label: "Datetime",
                    data: 'action=sel',
                    mode: 'datetime',
                    initial: '2017-06-18T06:15',
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

      when 'image carousel'
        reply_content(event, {
          type: 'template',
          altText: 'Image carousel alt text',
          template: {
            type: 'image_carousel',
            columns: [
              {
                imageUrl: 'https://fullout.jp/wp-content/uploads/2019/04/footlogo.jpg?1563441481',
                action: { label: 'line.me', type: 'uri', uri: 'https://fullout.jp', altUri: {desktop: 'https://www.naver.com'} }
              },
              {
                imageUrl: THUMBNAIL_URL,
                action: { label: 'postback', type: 'postback', data: 'hello world' }
              },
              {
                imageUrl: THUMBNAIL_URL,
                action: { label: 'message', type: 'message', text: 'This is message' }
              },
              {
                imageUrl: THUMBNAIL_URL,
                action: {
                  type: 'datetimepicker',
                  label: "Datetime",
                  data: 'action=sel',
                  mode: 'datetime',
                  initial: '2017-06-18T06:15',
                  max: '2100-12-31T23:59',
                  min: '1900-01-01T00:00'
                }
              }
            ]
          }
        })

      when 'imagemap'
        reply_content(event, {
          type: 'imagemap',
          baseUrl: THUMBNAIL_URL,
          altText: 'Imagemap alt text',
          baseSize: { width: 1024, height: 1024 },
          actions: [
            { area: { x: 0, y: 0, width: 512, height: 512 }, type: 'uri', linkUri: 'https://store.line.me/family/manga/en' },
            { area: { x: 512, y: 0, width: 512, height: 512 }, type: 'uri', linkUri: 'https://store.line.me/family/music/en' },
            { area: { x: 0, y: 512, width: 512, height: 512 }, type: 'uri', linkUri: 'https://store.line.me/family/play/en' },
            { area: { x: 512, y: 512, width: 512, height: 512 }, type: 'message', text: 'Fortune!' },
          ]
        })

      when 'imagemap video'
        video_url = File.join(settings.app_base_url.to_s, 'imagemap/video.mp4')
        preview_url = File.join(settings.app_base_url.to_s, 'imagemap/preview.jpg')
        reply_content(event, {
          type: 'imagemap',
          baseUrl: THUMBNAIL_URL,
          altText: 'Imagemap alt text',
          baseSize: { width: 1040, height: 1040 },
          video: {
            originalContentUrl: video_url,
            previewImageUrl: preview_url,
            area: {
              x: 0,
              y: 0,
              width: 520,
              height: 520,
            },
            external_link: {
              linkUri: 'https://line.me',
              label: 'LINE',
            },
          },
          actions: [
            { area: { x: 0, y: 0, width: 512, height: 512 }, type: 'uri', linkUri: 'https://store.line.me/family/manga/en' },
            { area: { x: 512, y: 0, width: 512, height: 512 }, type: 'uri', linkUri: 'https://store.line.me/family/music/en' },
            { area: { x: 0, y: 512, width: 512, height: 512 }, type: 'uri', linkUri: 'https://store.line.me/family/play/en' },
            { area: { x: 512, y: 512, width: 512, height: 512 }, type: 'message', text: 'Fortune!' },
          ]
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
                  text: "Header text"
                }
              ]
            },
            hero: {
              type: "image",
              url: HORIZONTAL_THUMBNAIL_URL,
              size: "full",
              aspectRatio: "4:3"
            },
            body: {
              type: "box",
              layout: "vertical",
              contents: [
                {
                  type: "text",
                  text: "Body text",
                }
              ]
            },
            footer: {
              type: "box",
              layout: "vertical",
              contents: [
                {
                  type: "text",
                  text: "Footer text",
                  align: "center",
                  color: "#888888"
                }
              ]
            }
          }
        })

      when 'flex carousel'
        reply_content(event, {
          type: "flex",
          altText: "this is a flex carousel",
          contents: {
            type: "carousel",
            contents: [
              {
                type: "bubble",
                body: {
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      wrap: true
                    }
                  ]
                },
                footer: {
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "button",
                      style: "primary",
                      action: {
                        type: "uri",
                        label: "Go",
                        uri: "https://example.com",
                        altUri: {
                          desktop: "https://example.com#desktop"
                        },
                      }
                    }
                  ]
                }
              },
              {
                type: "bubble",
                body: {
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "Hello, World!",
                      wrap: true
                    }
                  ]
                },
                footer: {
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "button",
                      style: "primary",
                      action: {
                        type: "uri",
                        label: "Go",
                        uri: "https://example.com",
                        altUri: {
                          desktop: "https://example.com#desktop"
                        }
                      }
                    }
                  ]
                }
              }
            ]
          }
        })

      when 'quickreply'
        reply_content(event, {
          type: 'text',
          text: '[QUICK REPLY]',
          quickReply: {
            items: [
              {
                type: "action",
                imageUrl: QUICK_REPLY_ICON_URL,
                action: {
                  type: "message",
                  label: "Sushi",
                  text: "Sushi"
                }
              },
              {
                type: "action",
                action: {
                  type: "location",
                  label: "Send location"
                }
              },
              {
                type: "action",
                imageUrl: QUICK_REPLY_ICON_URL,
                action: {
                  type: "camera",
                  label: "Open camera",
                }
              },
              {
                type: "action",
                imageUrl: QUICK_REPLY_ICON_URL,
                action: {
                  type: "cameraRoll",
                  label: "Open cameraRoll",
                }
              },
              {
                type: "action",
                action: {
                  type: "postback",
                  label: "buy",
                  data: "action=buy&itemid=111",
                  text: "buy",
                }
              },
              {
                type: "action",
                action: {
                  type: "message",
                  label: "Yes",
                  text: "Yes"
                }
              },
              {
                type: "action",
                action: {
                  type: "datetimepicker",
                  label: "Select date",
                  data: "storeId=12345",
                  mode: "datetime",
                  initial: "2017-12-25t00:00",
                  max: "2018-01-24t23:59",
                  min: "2017-12-25t00:00"
                }
              },
            ],
          },
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

        date = Date.yesterday
        date = date.to_s.delete"-"
        userInfo = client.get_number_of_followers(date)
        userInfo = JSON.parse(userInfo.read_body)
        messageNum = client.get_number_of_message_deliveries(date)
        messageNum = JSON.parse(messageNum.read_body)
        demo = client.get_friend_demographics
        demo = JSON.parse(demo.read_body)


        if event['source']['type'] == 'user'
          profile = client.get_profile(event['source']['userId'])
          profile = JSON.parse(profile.read_body)
          group_id = @parsed_body['destination']
          reply_text(event, [
            "Display name\n#{profile['displayName']}",
            "[ShowMeTheMoney]\n#{event.message['text']}"
          ])

          textFromUser(profile['displayName'],event.message['text'], event.message['id'], profile['userId'])
          update_group_in_friends(profile['userId'],group_id)
          #update_profile(profile['userId'],profile['displayName'],profile['pictureUrl'],profile['statusMessage'],)
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
    stickerFromUser(profile['displayName'], event.message['stickerId'], event.message['stickerId'], event.message['packageId'], profile['userId'])
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

  def textFromUser(sender,contents,message_id,fr_account)
    @message = Message.new({
      sender: sender,
      receiver: 'ShowMeTheMoney',
      contents: contents,
      message_type: 'text',
      message_id: message_id,
      fr_account: fr_account
    })
    if @message.save
      render json: 'api/messages', status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def stickerFromUser(sender,message_id,sticker_id,package_id,fr_account)
    @message = Message.new({
      sender: sender,
      receiver: 'FullouT',
      contents: "https://cdn.lineml.jp/api/media/sticker/#{package_id}_#{sticker_id}",
      message_type: 'sticker',
      message_id: message_id,
      sticker_id: sticker_id,
      package_id: package_id,
      fr_account: fr_account
    })
    if @message.save
      puts "save!"
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def add_friend(fr_account,fr_name,profile_pic,profile_msg)
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

  def update_group_in_friends(fr_account,group_id)
    @friend = Friend.find_by(fr_account: fr_account)
    @friend.update(group_id: group_id)
  end

  def update_message_profile(fr_account,fr_name)
    @messages = Message.where(fr_account: fr_account)
    if @messages.update(sender: fr_name)
      puts "profile updated"
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.fetch(:message, {}).permit(
      :id, :sender, :receiver, :contents, :created_at, :updated_at, :message_type, :message_id, :sticker_id, :package_id, :fr_account,
      )
  end
end
