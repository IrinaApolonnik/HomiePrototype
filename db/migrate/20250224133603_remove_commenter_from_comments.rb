class RemoveCommenterFromComments < ActiveRecord::Migration[7.2]
  def change
    remove_column :comments, :commenter, :string
  end
end
