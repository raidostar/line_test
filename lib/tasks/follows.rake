namespace :follows_update do
  desc "follows_block_update"
  task follow_block_update: :environment do

    @client1 = Line::Bot::Client.new do |config|
      config.channel_id = ENV["SHOW_ME_ID"]
      config.channel_secret = ENV["SHOW_ME_SECRET"]
      config.channel_token = ENV["SHOW_ME_TOKEN"]
      config.http_options = {
        open_timeout: 5,
        read_timeout: 5,
      }
    end
    @client2 = Line::Bot::Client.new do |config|
      config.channel_id = ENV["FULLOUT_CHANNEL_ID"]
      config.channel_secret = ENV["FULLOUT_CHANNEL_SECRET"]
      config.channel_token = ENV["FULLOUT_CHANNEL_TOKEN"]
      config.http_options = {
        open_timeout: 5,
        read_timeout: 5,
      }
    end
    # date = Date.yesterday
    # date = date.strftime("%Y%m%d")
    # data = @client.get_number_of_followers(date)
    # data = JSON.parse(data.read_body)

    # followers = data['followers']
    # targetedReaches = data['targetedReaches']
    # blocks = data['blocks']

    # @follow = Follow.new({group: 'FullouT', follower: followers, targetedReaches: targetedReaches, blocks: blocks})
    # @follow.save

    @text_msg1 = {
      type: 'text',
      text: '1번'
    }
    @text_msg2 = {
      type: 'text',
      text: '2번'
    }

    @options = Option.where(option_type: 'remindReply')
    @options.each do |opt|
      reaction_ids = opt.match_reaction.split(",")
      remind_contents = []
      reaction_ids.each do |id|
        reaction = Reaction.find(id)
        case reaction.attributes["reaction_type"]
        when "text"
          #contents = contents_converter(reaction.attributes["contents"])
          @client1.push_message("U2fc02a96720fe397ae6a10e0455d4190", @text_msg2)
          contents = {
            type: 'text',
            text: contents
          }
          @client1.push_message("U2fc02a96720fe397ae6a10e0455d4190", contents)
          remind_contents.push(contents)
        when "stamp"
          contents = reaction.attributes["contents"]
          contents = {
            type: 'sticker',
            packageId: 1,
            stickerId: contents[2..contents.length].to_i
          }
          remind_contents.push(contents)
        when "image"
          address = reaction.image.url.to_s
          contents = {
            type: "image",
            originalContentUrl: address,
            previewImageUrl: address
          }
          remind_contents.push(contents)
        when "map"
          contents = reaction.attributes["contents"]
          map_array = map_converter(contents)
          latlng_array = map_array[1].split(',')
          contents = {
            "type": "location",
            "title": "位置情報",
            "address": map_array[0],
            "latitude": latlng_array[0],
            "longitude": latlng_array[1]
          };
          remind_contents.push(contents)
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
          remind_contents.push(contents)
          remind_contents.push(image)
        end # case
      end # reaction_ids
      time = Time.new
      remind_time = opt.remind_after.to_i
      puts remind_time = time.days_ago(remind_time).end_of_day
      case opt.user_group
      when "ShowMeTheMoney"
        group = Group.find_by(group: "ShowMeTheMoney")
        friend = Friend.find_by(group_id: "U694f6894ce9a7b5d7dbaa82750e7f9f9")
        friends = Friend.where(group_id: group.group_id)
        message = {
          type: 'sticker',
          packageId: 1,
          stickerId: 12
        }
        message2 = {
          type: 'sticker',
          packageId: 1,
          stickerId: 2
        }
        #@client1.push_message("U2fc02a96720fe397ae6a10e0455d4190", remind_contents)
        friends.each do |fr|
          if fr.last_message_time < remind_time
            #@client1.push_message("U2fc02a96720fe397ae6a10e0455d4190", message)
          else
            #@client1.push_message("U2fc02a96720fe397ae6a10e0455d4190", message2)
          end
        end
      when "FullouT"

      end
    end # options.each

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
    # friends  = Friend.where(group_id: "U4996f6a0f7a044453858ff6ed933f5cc")
    # friends.each do |friend|
    #   id = "fr_account <<<<HERE"
    #   data = @client.push_message(id,message)
    #   data = JSON.parse(data.read_body)
    #   puts data
    #   sleep 2
    # end
  end
end