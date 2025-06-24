class RenameTypeInNotifications < ActiveRecord::Migration[7.2]
  def change
    rename_column :notifications, :type, :notification_type
  end
end
