class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels do |t|
      t.string :channel_name
      t.string :channel_id
      t.string :channel_secret
      t.string :channel_token
      t.string :channel_user_id
      t.string :status

      t.timestamps
    end
  end
end
