class RenameGroupIdColumnToNotifies < ActiveRecord::Migration[5.2]
  def up
    rename_column :notifies, :group_id, :channel_destination
  end
  def down
    rename_column :notifies, :channel_destination, :group_id
  end
end
