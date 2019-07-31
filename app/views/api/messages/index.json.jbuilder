json.set! :messages do
  json.array! @messages do |message|
    json.extract! message, :id, :sender, :receiver, :contents, :image_url
  end
end