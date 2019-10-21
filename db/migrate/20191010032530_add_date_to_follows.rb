class AddDateToFollows < ActiveRecord::Migration[5.2]
  def change
    add_column :follows, :date, :datetime
  end
end
