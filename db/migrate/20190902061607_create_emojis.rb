class CreateEmojis < ActiveRecord::Migration[5.2]
  def change
    create_table :emojis do |t|
      t.string :moji_text
      t.string :img_url
      t.string :unicode

      t.timestamps
    end
  end
end
