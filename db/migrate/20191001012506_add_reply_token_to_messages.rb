class AddReplyTokenToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :reply_token, :string
  end
end
