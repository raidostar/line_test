class CreateFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :follows do |t|
      t.string :group
      t.integer :follower
      t.integer :targetedReaches
      t.integer :blocks

      t.timestamps
    end
  end
end
