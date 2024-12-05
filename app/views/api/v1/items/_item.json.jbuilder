json.extract! item, :id, :name, :description, :image_url, :purchase_url, :price, :post_id, :created_at, :updated_at
json.url item_url(item, format: :json)
