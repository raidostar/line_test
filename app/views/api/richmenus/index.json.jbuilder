json.set! :richmenus do
  json.array! @richmenus do |richmenu|
    json.extract! richmenu, :id, :name, :contents, :image, :width, :height, :selected, :chat_bar_text, :created_at, :updated_at, :richmenu_id, :channel_id, :default_richmenu
  end
end