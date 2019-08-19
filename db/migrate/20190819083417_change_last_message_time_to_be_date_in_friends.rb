class ChangeLastMessageTimeToBeDateInFriends < ActiveRecord::Migration[5.2]
  def up
    change_column :friends,:last_message_time,:datetime
  end

  def down
    change_column :friends,:last_message_time,:string
  end
end
