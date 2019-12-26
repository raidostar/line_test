json.set! :friends do
  json.array! @friends do |friend|
    json.extract! friend, :id, :fr_account, :fr_name, :profile_pic, :profile_msg, :block, :created_at, :updated_at, :channel_destination, :last_message_time, :block_at, :follow_at, :tags, :last_message
  end
end