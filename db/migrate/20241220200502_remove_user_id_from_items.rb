class RemoveUserIdFromItems < ActiveRecord::Migration[7.2]
  def change
    remove_column :items, :user_id, :integer
  end
end
