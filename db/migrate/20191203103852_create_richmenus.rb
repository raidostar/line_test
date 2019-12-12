class CreateRichmenus < ActiveRecord::Migration[5.2]
  def change
    create_table :richmenus do |t|
      t.string :name
      t.string :contents
      t.string :image
      t.integer :width
      t.integer :height
      t.boolean :selected
      t.string :chat_bar_text

      t.timestamps
    end
  end
end
