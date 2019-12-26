class AddChannelsToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :channels, :string
    add_column :groups, :channels_limit, :integer
  end
end
