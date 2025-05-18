class RenameProfileIdToUserIdInLikes < ActiveRecord::Migration[7.2]
  def change
    rename_column :likes, :profile_id, :user_id
  end
end
