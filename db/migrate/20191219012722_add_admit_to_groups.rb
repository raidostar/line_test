class AddAdmitToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :admit, :boolean, default: false
    add_column :groups, :status, :string
  end
end
