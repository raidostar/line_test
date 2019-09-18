class CreateFriends < ActiveRecord::Migration[5.2]
  def change
    create_table :friends do |t|
      t.string :fr_account
      t.string :fr_name
      t.string :profile_pic
      t.string :profile_msg
      t.boolean :block, default: 0

      t.timestamps
    end
  end
end
