class AddTagsToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :tags, :string
  end
end
