class AddFooterDataToBubblesArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :bubbles_archives, :footer_data, :string
  end
end
