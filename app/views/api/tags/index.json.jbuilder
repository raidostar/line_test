json.set! :tags do
  json.array! @tags do |tag|
    json.extract! tag, :id, :name, :tag_group, :created_at, :updated_at
  end
end