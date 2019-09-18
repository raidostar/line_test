namespace :follows_update do
  desc "follows_block_update"
  task follow_block_update: :environment do

    @client = Line::Bot::Client.new do |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      config.http_options = {
        open_timeout: 5,
        read_timeout: 5,
      }
    end
    date = Date.yesterday
    date = date.strftime("%Y%m%d")
    data = @client.get_number_of_followers(date)
    data = JSON.parse(data.read_body)

    followers = data['followers']
    targetedReaches = data['targetedReaches']
    blocks = data['blocks']

    @follow = Follow.new({group: 'FullouT', follower: followers, targetedReaches: targetedReaches, blocks: blocks})
    @follow.save

    # message = {
    #   type: 'text',
    #   text: 'お知らせのテスト'
    # }
    # friends  = Friend.where(group_id: "U4996f6a0f7a044453858ff6ed933f5cc")
    # friends.each do |friend|
      # id = "fr_account <<<<HERE"
      # data = @client.push_message(id,message)
      # data = JSON.parse(data.read_body)
      # puts data
      # sleep 2
    # end
  end
end