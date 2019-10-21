class AddDisneyPointToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :disney_point, :integer, default: 0
  end
end
