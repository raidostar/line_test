json.set! :reaction do
  json.extract! @reaction, :id, :name, :contents, :reaction_type, :channel_id, :tag, :target_number, :image, :created_at, :updated_at, :bool, :match_option
end