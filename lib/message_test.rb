require 'line/bot'

def client
  @client ||= Line::Bot::Client.new do |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = "79IIbPiL+m3o3nIJqZcTnKIN1wSjZu5+pgLiqqdWfbx26oKTJSqokXBul+JkUeC/PQ5yhZi5YX8XtUAT5/JYb8q3lwKA84Eb+OHLMW0j5RHBz2ieQpQcY/kvMpeIuuCG6g080f229NGUpwGS3cjrUwdB04t89/1O/w1cDnyilFU="
    config.http_options = {
      open_timeout: 5,
      read_timeout: 5,
    }
  end
end

message = {
  "type": "text",
  "text": "test"+0x100001.chr("UTF-8")
};

client.push_message("U0c17e4f634a18b416bcbf050a50b68fb",message)