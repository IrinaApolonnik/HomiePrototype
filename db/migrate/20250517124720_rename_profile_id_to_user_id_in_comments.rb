class RenameProfileIdToUserIdInComments < ActiveRecord::Migration[7.2]
  def change
    rename_column :comments, :profile_id, :user_id
  end
end
