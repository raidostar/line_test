class AddGroupKeyToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :group_key, :string
  end
end
