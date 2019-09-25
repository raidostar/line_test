class RenameTargetNumberColumnToNotifies < ActiveRecord::Migration[5.2]
  def up
    rename_column :notifies, :target_number, :hit_count
  end
  def down
    rename_column :notifies, :hit_count, :target_number
  end
end
