class ChangeContentsToBeTextInNotifies < ActiveRecord::Migration[5.2]
  def up
    change_column :notifies,:contents,:text
  end

  def down
    change_column :notifies,:contents,:string
  end
end
