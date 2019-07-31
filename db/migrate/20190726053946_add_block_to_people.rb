class AddBlockToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :block, :boolean
  end
end
