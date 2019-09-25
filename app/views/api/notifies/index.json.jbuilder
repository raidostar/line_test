json.set! :notifies do
  json.array! @notifies do |notify|
    json.extract! notify, :id, :sender, :receiver, :contents, :created_at, :updated_at, :notify_type, :group_id, :target_tag, :hit_count, :image
  end
end