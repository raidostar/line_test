class RenameUserGroupColumnToReactions < ActiveRecord::Migration[5.2]
  def up
    rename_column :reactions, :user_group, :channel_id
  end
  def down
    rename_column :reactions, :channel_id, :user_group
  end
end
