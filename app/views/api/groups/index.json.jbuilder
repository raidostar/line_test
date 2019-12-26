json.set! :groups do
  json.array! @groups do |group|
    json.extract! group, :id, :group, :created_at, :updated_at, :admit, :status, :channels, :channels_limit, :member_limit
  end
end