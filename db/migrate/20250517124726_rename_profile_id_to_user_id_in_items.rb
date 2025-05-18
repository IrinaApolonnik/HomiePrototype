class RenameProfileIdToUserIdInItems < ActiveRecord::Migration[7.2]
  def change
    rename_column :items, :profile_id, :user_id
  end
end
