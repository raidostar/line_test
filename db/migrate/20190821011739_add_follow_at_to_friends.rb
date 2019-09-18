class AddFollowAtToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :follow_at, :datetime
  end
end
