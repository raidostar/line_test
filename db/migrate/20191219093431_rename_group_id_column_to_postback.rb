class RenameGroupIdColumnToPostback < ActiveRecord::Migration[5.2]
  def up
    rename_column :postbacks, :group_id, :channel_destination
  end
  def down
    rename_column :postbacks, :channel_destination, :group_id
  end
end
