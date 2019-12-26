class AddRichmenuIdToRichmenus < ActiveRecord::Migration[5.2]
  def change
    add_column :richmenus, :richmenu_id, :string
  end
end
