json.set! :message do
  json.extract! @message, :sender, :receiver, :contents, :image_url
end