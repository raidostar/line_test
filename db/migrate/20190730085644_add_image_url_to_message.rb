class AddImageUrlToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :image_url, :string
  end
end
