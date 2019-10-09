class AddCheckStatusToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :check_status, :string
  end
end
