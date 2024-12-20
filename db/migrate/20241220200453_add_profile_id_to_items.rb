class AddProfileIdToItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :items, :profile, null: false, foreign_key: true
  end
end
