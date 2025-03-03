class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :post_id, :profile_id, :created_at, :updated_at

  belongs_to :post
  belongs_to :profile
  has_many :replies
end