class AddRemindBoolToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :remind_bool, :boolean, default: true
  end
end
