class CollectionSerializer < ActiveModel::Serializer
  attributes :id, :title, :private, :image_url
  has_one :profile
end
