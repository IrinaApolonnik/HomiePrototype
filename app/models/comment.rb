class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :profile

  has_many :replies, class_name: "Comment", foreign_key: "comment_id", dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  belongs_to :comment, optional: true

  default_scope { order(created_at: "DESC") }
  scope :not_replies, -> { where(comment_id: nil) }

  def root_comment
    comment.present? ? comment.root_comment : self
  end
end
