class CreateReactions < ActiveRecord::Migration[5.2]
  def change
    create_table :reactions do |t|
      t.string :name
      t.text :contents
      t.string :reaction_type
      t.string :user_group
      t.string :target_tag
      t.integer :target_number
      t.string :image

      t.timestamps
    end
  end
end
