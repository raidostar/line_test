json.set! :postback do
  json.extract! @postback, :id, :sender, :receiver, :data, :fr_account, :channel_destination, :reply_token, :created_at, :updated_at
end