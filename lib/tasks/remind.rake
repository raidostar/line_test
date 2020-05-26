namespace :daily do
  desc "remind_daily_check"
  task remind_reply: :environment do

    def option_checker(option,channel_destination)
      tags = option.tag.split(",")
      if tags.include?('ALL')
        target_friends = Friend.where(channel_destination: channel_destination)
      else
        target_friends = Friend.where(channel_destination: channel_destination,tags: tags)
      end
      return target_friends
    end

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

    def contents_converter(contents)
      if contents.include?("<br>&nbsp;<div>")
        contents = contents.gsub(/<div>/,"\n")
        contents = contents.gsub(/<\/div>/,'')
        contents = contents.gsub(/<br>/,'')
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

    def map_converter(contents)
      address_array = contents.split('+')
      address_array[0] = address_array[0].gsub(/日本、/,'')
      address_array[1] = address_array[1].gsub(/\[@map\(/,'').gsub(/\)]/,'')
      return address_array
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

    @options = Option.where(option_type: 'remindReply')
    @options.each do |opt|
      channel_id = opt.channel_id
      @channel = Channel.find_by(channel_id: channel_id)
      channel_name = @channel.channel_name
      channel_secret = @channel.channel_secret
      channel_token = @channel.channel_token
      channel_destination = @channel.channel_destination
      @client = make_client(channel_id,channel_secret,channel_token)
      fr_accounts = []
      @friends = option_checker(opt,channel_destination)
      @remind_after = opt.remind_after.to_i

      reaction_ids = opt.match_reaction.split(",")
      remind_contents = []
      reaction_ids.each do |id|
        reaction = Reaction.find(id)
        @message = Message.new({sender: channel_name, receiver: opt.tag, fr_account: channel_destination, channel_destination: channel_destination, check_status: 'reminded'})
        case reaction.attributes["reaction_type"]
        when "text"
          @message.contents = reaction.contents
          @message.message_type = 'text'
          contents = contents_converter(reaction.contents)
          contents = {
            type: 'text',
            text: contents
          }
          @message.save
          remind_contents.push(contents)
        when "stamp"
          @message.contents = reaction.contents
          @message.message_type = 'stamp'
          id_split = reaction.contents.split("_")
          @message.package_id = id_split[0]
          @message.sticker_id = id_split[1]
          contents = reaction.attributes["contents"]

          contents = {
            type: 'sticker',
            packageId: id_split[0],
            stickerId: id_split[1]
          }
          @message.save
          remind_contents.push(contents)
        when "image"
          address = reaction.image.url.to_s
          @message.contents = address
          @message.message_type = "image"
          @message.image = reaction.image
          contents = {
            type: "image",
            originalContentUrl: address,
            previewImageUrl: address
          }
          @message.save
          remind_contents.push(contents)
        when "map"
          contents = reaction.attributes["contents"]
          @message.contents = contents
          @message.message_type = "map"
          map_array = map_converter(contents)
          latlng_array = map_array[1].split(',')
          contents = {
            "type": "location",
            "title": "位置情報",
            "address": map_array[0],
            "latitude": latlng_array[0],
            "longitude": latlng_array[1]
          };
          @message.save
          remind_contents.push(contents)
        when "text+image"
          @message.contents = reaction.contents
          @message.image = reaction.image
          @message.message_type = 'text+image'
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
          @message.save
          remind_contents.push(contents)
          remind_contents.push(image)
        when "carousel"
          bubble_list = []
          bubble_ids = reaction.contents.split(",")
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
          @message.contents = reaction.contents
          @message.message_type = 'carousel'
          @message.save
          remind_contents.push(contents)
        end # case
      end # reaction_ids
      @friends.each do |friend|
        time = DateTime.current
        time = time.end_of_day
        standard_time = time.prev_day(@remind_after)

        if !friend.last_message_time.present? || (friend.last_message_time <= standard_time)
          @client.push_message(friend.fr_account, remind_contents)
        end
      end
    end # options.each
  end
end