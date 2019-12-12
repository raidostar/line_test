json.set! :richaction do
  json.extract! @richaction, :id, :x, :y, :width, :height, :richaction_type, :text, :uri, :data, :created_at, :updated_at
end