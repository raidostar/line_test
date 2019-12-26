class AddChannelDestinationToChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :channel_destination, :string
  end
end
