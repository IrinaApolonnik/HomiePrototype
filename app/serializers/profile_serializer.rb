class ProfileSerializer < ActiveModel::Serializer
    attributes :id, :username, :name, :bio, :avatar_url, :created_at, :updated_at
    has_many :posts
  end