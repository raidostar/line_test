json.set! :emoji do
  json.extract! @emoji, :id,:moji_text,:img_url,:created_at,:updated_at
end