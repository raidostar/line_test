class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :group
      t.string :group_id

      t.timestamps
    end
  end
end
