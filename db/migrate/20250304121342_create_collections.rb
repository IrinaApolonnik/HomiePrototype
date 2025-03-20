class CreateCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :collections do |t|
      t.string :title
      t.boolean :private
      t.string :image_url
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
