class TagSerializer < ActiveModel::Serializer
    attributes :id, :name, :created_at, :updated_at
    belongs_to :tag_category
  end