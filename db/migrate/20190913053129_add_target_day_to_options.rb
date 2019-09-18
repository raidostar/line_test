class AddTargetDayToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :target_day, :string
    add_column :options, :target_time, :string
    add_column :options, :target_keyword, :string
    add_column :options, :target_friend, :string
  end
end
