class AddUserGroupToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :user_group, :string
  end
end
