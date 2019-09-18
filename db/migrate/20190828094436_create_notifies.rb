class CreateNotifies < ActiveRecord::Migration[5.2]
  def change
    create_table :notifies do |t|
      t.string :sender
      t.string :receiver
      t.string :contents
      t.string :notify_type
      t.string :fr_account
      t.string :group_id
      t.string :target_tag

      t.timestamps
    end
  end
end
