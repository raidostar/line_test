class AddMemberLimitToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :member_limit, :integer
  end
end
