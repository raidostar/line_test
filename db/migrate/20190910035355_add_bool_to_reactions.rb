class AddBoolToReactions < ActiveRecord::Migration[5.2]
  def change
    add_column :reactions, :bool, :boolean, default: false
  end
end
