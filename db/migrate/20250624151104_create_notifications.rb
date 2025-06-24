class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :actor, polymorphic: true, null: false
      t.references :notifiable, polymorphic: true, null: false
      t.text :content
      t.string :type
      t.boolean :read_status

      t.timestamps
    end
  end
end
