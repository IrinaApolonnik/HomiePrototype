class CommentSerializer < ActiveModel::Serializer
    attributes :id, :body, :created_at, :updated_at
    belongs_to :profile
    belongs_to :post
  end