json.set! :friend do
  json.extract! @friend, :id, :fr_account, :fr_name, :profile_pic, :profile_msg, :block, :created_at, :updated_at, :group_id, :last_message_time, :block_at, :follow_at, :tags, :last_message
end