class RenameGroupKeyColumnToGroups < ActiveRecord::Migration[5.2]
  def up
    rename_column :groups, :group_key, :password_digest
  end
  def down
    rename_column :groups, :password_digest, :group_key
  end
end
