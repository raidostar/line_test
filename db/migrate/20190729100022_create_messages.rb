class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :sender
      t.string :receiver
      t.string :contents

      t.timestamps
    end
  end
end
