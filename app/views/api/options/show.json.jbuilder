json.set! :option do
  json.extract! @option, :id, :name, :match_reaction, :action_count, :tag, :created_at, :updated_at, :user_group, :target_day, :target_time, :target_keyword, :target_friend
end