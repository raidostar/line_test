class AddJoinInToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :join_in, :date
  end
end
