class RenameGroupIdColumnToMessages < ActiveRecord::Migration[5.2]
  def up
    rename_column :messages, :group_id, :channel_destination
  end
  def down
    rename_column :messages, :channel_destination, :group_id
  end
end
