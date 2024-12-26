class ItemSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :image_url, :purchase_url, :price, :market_icon_url, :created_at, :updated_at
  
    belongs_to :profile
    belongs_to :post, optional: true
  end