class LikeSerializer < ActiveModel::Serializer
    attributes :id, :likeable_type, :likeable_id, :created_at
    belongs_to :profile
  end