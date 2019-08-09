json.set! :friend do
  json.extract! @friend, :fr_account, :fr_name, :profile_pic, :profile_msg, :block
end