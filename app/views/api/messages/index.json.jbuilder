json.set! :messages do
  json.array! @messages do |message|
    json.extract! message, :id, :sender, :receiver, :contents, :created_at, :updated_at, :message_type, :message_id, :sticker_id, :package_id, :check_status, :reply_token, :fr_account, :channel_destination, :image
  end
end