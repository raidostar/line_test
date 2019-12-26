class RenameUserGroupColumnToOptions < ActiveRecord::Migration[5.2]
  def up
    rename_column :options, :user_group, :channel_id
  end
  def down
    rename_column :options, :channel_id, :user_group
  end
end
