class ChangeBlockAtToBeDatetimeInFriends < ActiveRecord::Migration[5.2]
  def up
    change_column :friends,:block_at,:datetime
  end

  def down
    change_column :friends,:block_at,:date
  end
end
