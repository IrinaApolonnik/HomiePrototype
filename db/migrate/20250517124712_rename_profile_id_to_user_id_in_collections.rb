class RenameProfileIdToUserIdInCollections < ActiveRecord::Migration[7.2]
  def change
    rename_column :collections, :profile_id, :user_id
  end
end
