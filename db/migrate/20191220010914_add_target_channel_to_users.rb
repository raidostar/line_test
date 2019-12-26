class AddTargetChannelToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :target_channel, :string
  end
end
