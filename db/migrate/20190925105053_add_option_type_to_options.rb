class AddOptionTypeToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :options, :option_type, :string
  end
end
