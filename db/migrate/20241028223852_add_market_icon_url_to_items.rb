class AddMarketIconUrlToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :market_icon_url, :string
  end
end
