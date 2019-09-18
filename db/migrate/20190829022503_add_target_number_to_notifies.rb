class AddTargetNumberToNotifies < ActiveRecord::Migration[5.2]
  def change
    add_column :notifies, :target_number, :integer
  end
end
