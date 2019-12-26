json.set! :richmenu do
  json.extract! @richmenu, :id, :name, :contents, :image, :width, :height, :selected, :chat_bar_text, :created_at, :updated_at, :richmenu_id, :channel_id, :default_richmenu
end