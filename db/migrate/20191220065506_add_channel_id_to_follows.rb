class AddChannelIdToFollows < ActiveRecord::Migration[5.2]
  def up
    add_column :follows, :channel_id, :string
  end
  def down
    remove_column :follows, :channel_id
  end
end
