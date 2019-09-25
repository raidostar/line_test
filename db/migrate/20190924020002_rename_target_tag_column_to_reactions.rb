class RenameTargetTagColumnToReactions < ActiveRecord::Migration[5.2]
  def up
    rename_column :reactions, :target_tag, :tag
  end
  def down
    rename_column :reactions, :tag, :target_tag
  end
end
