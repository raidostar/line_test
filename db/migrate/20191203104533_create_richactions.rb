class CreateRichactions < ActiveRecord::Migration[5.2]
  def change
    create_table :richactions do |t|
      t.integer :x
      t.integer :y
      t.integer :width
      t.integer :height
      t.string :type
      t.string :text
      t.string :uri
      t.string :data

      t.timestamps
    end
  end
end
