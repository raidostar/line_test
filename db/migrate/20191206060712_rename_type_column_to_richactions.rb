class RenameTypeColumnToRichactions < ActiveRecord::Migration[5.2]
  def up
    rename_column :richactions, :type, :richaction_type
  end
  def down
    rename_column :richactions, :richaction_type, :type
  end
end
