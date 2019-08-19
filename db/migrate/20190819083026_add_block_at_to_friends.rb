class AddBlockAtToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :block_at, :date
  end
end
