json.set! :emojis do
  json.array! @emojis do |emoji|
    json.extract! emoji, :id, :moji_text,:img_url,:created_at,:updated_at
  end
end