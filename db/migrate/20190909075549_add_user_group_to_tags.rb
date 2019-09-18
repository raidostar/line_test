class AddUserGroupToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :user_group, :string
  end
end
