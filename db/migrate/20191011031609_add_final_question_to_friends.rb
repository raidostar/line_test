class AddFinalQuestionToFriends < ActiveRecord::Migration[5.2]
  def change
    add_column :friends, :final_question, :integer, default: 0
  end
end
