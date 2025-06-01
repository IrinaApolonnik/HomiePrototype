class AddDefaultToCollections < ActiveRecord::Migration[7.2]
  def change
    add_column :collections, :default, :boolean, default: false
  end
end
