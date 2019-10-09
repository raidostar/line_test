class AddBoolToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :bool, :boolean, default: false
  end
end
