class AddGroupToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :group, :string, default: false
  end
end
