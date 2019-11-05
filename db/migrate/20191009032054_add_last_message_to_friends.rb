class AddLastMessageToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :last_message, :text
  end
end
