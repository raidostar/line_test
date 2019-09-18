class AddMatchOptionToReactions < ActiveRecord::Migration[5.2]
  def change
    add_column :reactions, :match_option, :string
  end
end
