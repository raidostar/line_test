class AddImageToNotifies < ActiveRecord::Migration[5.2]
  def change
    add_column :notifies, :image, :string
  end
end
