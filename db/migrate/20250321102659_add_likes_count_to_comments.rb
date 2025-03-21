class AddLikesCountToComments < ActiveRecord::Migration[7.2]
  def change
    add_column :comments, :likes_count, :integer, default: 0
  end
end
