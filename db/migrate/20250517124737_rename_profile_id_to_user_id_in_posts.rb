class RenameProfileIdToUserIdInPosts < ActiveRecord::Migration[7.2]
  def change
    rename_column :posts, :profile_id, :user_id
  end
end
