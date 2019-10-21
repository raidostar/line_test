json.set! :follow do
  json.extract! @follow, :id, :group, :follower, :targetedReaches, :block, :created_at, :updated_at, :date
end