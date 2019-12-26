json.set! :user do
  json.extract! @user, :id,:email,:created_at,:updated_at,:group,:status,:target_channel, :admit
end