class RenameUserGroupColumnToTags < ActiveRecord::Migration[5.2]
  def up
    rename_column :tags, :user_group, :channel_id
  end
  def down
    rename_column :tags, :channel_id, :user_group
  end
end
