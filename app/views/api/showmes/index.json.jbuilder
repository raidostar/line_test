json.set! :notifies do
  json.array! @notifies do |message|
    json.extract! notify, :id, :sender, :receiver, :contents, :created_at, :updated_at, :notify_type
  end
end