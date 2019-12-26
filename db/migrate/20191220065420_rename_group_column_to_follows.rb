class RenameGroupColumnToFollows < ActiveRecord::Migration[5.2]
  def up
    rename_column :follows, :group, :channel_name
  end
  def down
    rename_column :follows, :channel_name, :group
  end
end
