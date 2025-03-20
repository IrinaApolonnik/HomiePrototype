json.extract! collection, :id, :title, :private, :image_url, :profile_id, :created_at, :updated_at
json.url collection_url(collection, format: :json)
