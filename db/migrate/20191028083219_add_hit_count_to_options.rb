class AddHitCountToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :hit_count, :integer, default: 0
  end
end
