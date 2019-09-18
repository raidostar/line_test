class AddWithdrawAtToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :withdraw_at, :date
  end
end
