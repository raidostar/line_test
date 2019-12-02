require 'line/bot'

DEFAULT_SLEEP = 2.freeze

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

for i in 1..7 do
  datetime = DateTime.now
  datetime = datetime.beginning_of_day
  datetime = datetime - i
  temp = datetime.strftime("%Y%m%d")
  follows = client.get_number_of_followers(temp)
  body = follows.body
  parsed_body = JSON.parse(body)
  followers = parsed_body["followers"]
  targetedReaches = parsed_body["targetedReaches"]
  blocks = parsed_body["blocks"]
  @follow = Follow.new({group: 'FullouT',follower: followers, targetedReaches: targetedReaches, blocks: blocks, date: datetime})
  @follow.save
  sleep DEFAULT_SLEEP
end
