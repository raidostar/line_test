class AddRemindAfterToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :remind_after, :string
  end
end
