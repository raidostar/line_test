class AddTypeAndTimeToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :message_type, :string
    add_column :messages, :message_id, :string
    add_column :messages, :sticker_id, :string
    add_column :messages, :package_id, :string
  end
end
