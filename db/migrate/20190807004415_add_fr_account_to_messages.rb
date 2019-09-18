class AddFrAccountToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :fr_account, :string
  end
end
