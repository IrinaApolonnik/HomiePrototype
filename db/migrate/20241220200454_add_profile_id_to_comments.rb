class AddProfileIdToComments < ActiveRecord::Migration[7.2]
  def change
    add_reference :comments, :profile, null: false, foreign_key: true
  end
end
