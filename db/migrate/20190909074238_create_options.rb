class CreateOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :options do |t|
      t.string :name
      t.string :match_action
      t.integer :action_count
      t.string :tag

      t.timestamps
    end
  end
end
