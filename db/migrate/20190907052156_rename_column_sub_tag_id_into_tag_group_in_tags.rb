class RenameColumnSubTagIdIntoTagGroupInTags < ActiveRecord::Migration[5.2]
  def up
    rename_column :tags, :sub_tag_id, :tag_group
  end

  def down
    rename_column :tags,:tag_group, :sub_tag_id
  end
end
