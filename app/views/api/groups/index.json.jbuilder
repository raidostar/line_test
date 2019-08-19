json.set! :groups do
  json.array! @groups do |group|
    json.extract! group, :id,:group,:group_id,:created_at,:updated_at,:group_key
  end
end