class AddUserGroupToRichmenus < ActiveRecord::Migration[5.2]
  def change
    add_column :richmenus, :user_group, :string
  end
end
