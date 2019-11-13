class AddBubbleColumnsToBubble < ActiveRecord::Migration[5.2]
  def change
    add_column :bubbles, :header_size, :string
    add_column :bubbles, :header_gravity, :string
    add_column :bubbles, :header_align, :string
    add_column :bubbles, :header_bold, :string
    add_column :bubbles, :header_color, :string
    add_column :bubbles, :header_background, :string
    add_column :bubbles, :hero_size, :string
    add_column :bubbles, :hero_align, :string
    add_column :bubbles, :hero_ratio, :string
    add_column :bubbles, :hero_background, :string
    add_column :bubbles, :body_size, :string
    add_column :bubbles, :body_gravity, :string
    add_column :bubbles, :body_align, :string
    add_column :bubbles, :body_bold, :string
    add_column :bubbles, :body_color, :string
    add_column :bubbles, :body_background, :string
    add_column :bubbles, :footer_size, :string
    add_column :bubbles, :footer_gravity, :string
    add_column :bubbles, :footer_align, :string
    add_column :bubbles, :footer_bold, :string
    add_column :bubbles, :footer_color, :string
    add_column :bubbles, :footer_background, :string
    add_column :bubbles, :footer_button, :string
    add_column :bubbles, :footer_uri, :string
    add_column :bubbles, :footer_message, :string
  end
end
