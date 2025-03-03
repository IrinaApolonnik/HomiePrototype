class LikeSerializer < ActiveModel::Serializer
    attributes :id, :likeable_type, :likeable_id, :created_at
  belongs_to :profile
  belongs_to :likeable, polymorphic: true
  end