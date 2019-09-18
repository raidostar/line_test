class AddGroupIdToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :group_id, :string
  end
end
