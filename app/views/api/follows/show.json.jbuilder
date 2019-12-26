json.set! :follow do
  json.extract! @follow, :id, :channel_name, :follower, :targetedReaches, :block, :created_at, :updated_at, :date, :channel_id
end