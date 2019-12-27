json.set! :channels do
  json.array! @channels do |channel|
    json.extract! channel, :id, :channel_name, :channel_id, :channel_secret, :channel_token, :channel_user_id, :status, :created_at, :updated_at, :channel_destination, :image
  end
end