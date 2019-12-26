json.set! :tag do
  json.extract! @tag, :id, :name, :tag_group, :created_at, :updated_at, :channel_id
end