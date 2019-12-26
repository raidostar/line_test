json.set! :group do
  json.extract! @group, :id, :group, :created_at, :updated_at, :admit, :status, :channels, :channels_limit, :member_limit
end
