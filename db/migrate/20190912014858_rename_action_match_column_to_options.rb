class RenameActionMatchColumnToOptions < ActiveRecord::Migration[5.2]
  def up
    rename_column :options, :match_action, :match_reaction
  end
  def down
    rename_column :options, :match_reaction, :match_action
  end
end
