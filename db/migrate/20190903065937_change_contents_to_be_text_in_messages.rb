class ChangeContentsToBeTextInMessages < ActiveRecord::Migration[5.2]
  def up
    change_column :messages,:contents,:text
  end

  def down
    change_column :messages,:contents,:string
  end
end
