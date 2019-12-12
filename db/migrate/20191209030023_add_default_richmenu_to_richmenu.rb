class AddDefaultRichmenuToRichmenu < ActiveRecord::Migration[5.2]
  def change
    add_column :richmenus, :default_richmenu, :boolean, default: false
  end
end
