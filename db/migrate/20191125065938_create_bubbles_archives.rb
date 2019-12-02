class CreateBubblesArchives < ActiveRecord::Migration[5.2]
  def change
    create_table :bubbles_archives do |t|
      t.string :header
      t.string :image
      t.text :body
      t.string :footer_type
      t.string :footer

      t.string :header_size
      t.string :header_gravity
      t.string :header_align
      t.string :header_bold
      t.string :header_color
      t.string :header_background

      t.string :hero_size
      t.string :hero_align
      t.string :hero_ratio
      t.string :hero_background

      t.string :body_size
      t.string :body_gravity
      t.string :body_align
      t.string :body_bold
      t.string :body_color
      t.string :body_background

      t.string :footer_size
      t.string :footer_gravity
      t.string :footer_align
      t.string :footer_bold
      t.string :footer_color
      t.string :footer_background
      t.string :footer_button
      t.string :footer_uri
      t.string :footer_message

      t.timestamps
    end
  end
end
