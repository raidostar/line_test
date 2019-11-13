class RenameHeroColumnToBubbles < ActiveRecord::Migration[5.2]
  def up
    rename_column :bubbles, :hero, :image
  end
  def down
    rename_column :bubbles, :hero, :image
  end
end
