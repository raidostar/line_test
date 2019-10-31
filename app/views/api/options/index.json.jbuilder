json.set! :options do
  json.array! @options do |option|
    json.extract! option, :id, :name, :match_reaction, :action_count, :tag, :created_at, :updated_at, :user_group, :target_day, :target_time, :target_keyword, :target_friend, :option_type, :remind_after, :bool
  end
end