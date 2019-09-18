class ChangeTagGroupToBeTextTnTags < ActiveRecord::Migration[5.2]
  def up
    change_column :tags,:tag_group,:string
  end

  def down
    change_column :tags,:tag_group,:integer
  end
end
