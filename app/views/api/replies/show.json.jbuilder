json.set! :replies do
  json.extract! @reply, :id, :sender, :receiver, :contents, :created_at, :updated_at, :reply_type, :reply_token, :sticker_id, :package_id
end