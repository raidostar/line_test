json.set! :reactions do
  json.array! @reactions do |reaction|
    json.extract! reaction, :id, :name, :contents, :reaction_type, :user_group, :tag, :target_number, :image, :created_at, :updated_at, :bool, :match_option
  end
end