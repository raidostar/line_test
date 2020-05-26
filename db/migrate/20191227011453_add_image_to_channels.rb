class AddImageToChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :image, :string
  end
end
