class AddReleaseAtToBooks < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :release_at, :date
  end
end
