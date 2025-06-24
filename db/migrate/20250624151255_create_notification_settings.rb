class CreateNotificationSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notification_type
      t.boolean :enabled

      t.timestamps
    end
  end
end
