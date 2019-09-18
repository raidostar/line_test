json.set! :message do
  json.extract! @message, :sender, :receiver, :contents, :created_at, :updated_at, :message_type, :message_id, :sticker_id, :package_id, :fr_account
end