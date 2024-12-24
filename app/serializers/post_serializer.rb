class PostSerializer < ActiveModel::Serializer
    attributes :id, :title, :description, :image_url, :public, :created_at, :updated_at
    belongs_to :profile
    has_many :comments
  end