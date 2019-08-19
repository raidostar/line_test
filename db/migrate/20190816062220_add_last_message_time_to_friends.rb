class AddLastMessageTimeToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :last_message_time, :string
  end
end
