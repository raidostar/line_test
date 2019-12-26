json.set! :postbacks do
  json.array! @postbacks do |postback|
    json.extract! postback, :id, :sender, :receiver, :data, :fr_account, :channel_destination, :reply_token, :created_at, :updated_at
  end
end