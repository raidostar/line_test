class AddAdmitToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :admit, :boolean, default: true
  end
end
