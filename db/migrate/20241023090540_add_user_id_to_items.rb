class AddUserIdToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :user_id, :integer
  end
end
