class RenameUserGroupColumnToRichmenus < ActiveRecord::Migration[5.2]
  def up
    rename_column :richmenus, :user_group, :channel_id
  end
  def down
    rename_column :richmenus, :channel_id, :user_group
  end
end
