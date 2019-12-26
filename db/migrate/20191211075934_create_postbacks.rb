class CreatePostbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :postbacks do |t|
      t.string :sender
      t.string :receiver
      t.text :data
      t.string :fr_account
      t.string :group_id
      t.string :reply_token

      t.timestamps
    end
  end
end
