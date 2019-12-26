class RenameGroupIdColumnToFriends < ActiveRecord::Migration[5.2]
  def up
    rename_column :friends, :group_id, :channel_destination
  end
  def down
    rename_column :friends, :channel_destination, :group_id
  end
end
