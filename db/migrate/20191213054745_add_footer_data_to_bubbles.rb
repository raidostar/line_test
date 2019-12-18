class AddFooterDataToBubbles < ActiveRecord::Migration[5.2]
  def change
    add_column :bubbles, :footer_data, :string
  end
end
