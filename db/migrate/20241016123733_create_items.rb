class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.string :image_url
      t.string :purchase_url
      t.decimal :price
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
