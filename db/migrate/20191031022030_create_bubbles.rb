class CreateBubbles < ActiveRecord::Migration[5.2]
  def change
    create_table :bubbles do |t|
      t.string :header
      t.string :hero
      t.text :body
      t.string :footer_type
      t.string :footer

      t.timestamps
    end
  end
end
