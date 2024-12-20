class RemoveUserIdFromComments < ActiveRecord::Migration[7.2]
  def change
    remove_column :comments, :user_id, :integer
  end
end
