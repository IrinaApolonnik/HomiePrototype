class AddTagCategoryToTags < ActiveRecord::Migration[7.2]
  def change
    add_reference :tags, :tag_category, foreign_key: true, null: true
  end
end
