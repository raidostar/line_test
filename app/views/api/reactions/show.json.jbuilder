json.set! :reaction do
  json.extract! @reaction, :id, :name, :contents, :reaction_type, :user_group, :target_tag, :target_number, :image, :created_at, :updated_at, :bool, :match_option
end