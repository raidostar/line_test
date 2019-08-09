json.set! :friends do
  json.array! @friends do |friend|
    json.extract! friend, :id, :fr_account, :fr_name, :profile_pic, :profile_msg, :block, :created_at, :updated_at
  end
end