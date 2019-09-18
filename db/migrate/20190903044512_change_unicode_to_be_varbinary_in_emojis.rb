class ChangeUnicodeToBeVarbinaryInEmojis < ActiveRecord::Migration[5.2]
  def up
    change_column :emojis,:unicode,:binary
  end

  def down
    change_column :emojis,:unicode,:string
  end
end
