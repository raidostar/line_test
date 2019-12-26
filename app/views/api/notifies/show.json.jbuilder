json.set! :notify do
  json.extract! @notify, :id, :sender, :receiver, :contents, :created_at, :updated_at, :notify_type, :channel_destination, :target_tag, :hit_count, :image
end