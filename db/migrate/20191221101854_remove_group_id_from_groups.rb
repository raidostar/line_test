class RemoveGroupIdFromGroups < ActiveRecord::Migration[5.2]
  def up
    remove_column :groups, :group_id
  end
  def down
    add_column :groups, :group_id, :string
  end
end
