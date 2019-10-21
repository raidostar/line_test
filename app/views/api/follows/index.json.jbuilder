json.set! :follows do
  json.array! @follows do |follow|
    json.extract! follow, :id, :group, :follower, :targetedReaches, :block, :created_at, :updated_at, :date
  end
end