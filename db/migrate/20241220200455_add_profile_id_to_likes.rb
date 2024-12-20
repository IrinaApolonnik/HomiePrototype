class AddProfileIdToLikes < ActiveRecord::Migration[7.2]
  def change
    add_reference :likes, :profile, null: false, foreign_key: true
  end
end
