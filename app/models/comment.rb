class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  has_many :replies, class_name: "Comment", foreign_key: "comment_id", dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  belongs_to :comment, optional: true

  default_scope { order(created_at: "DESC") }
  scope :not_replies, -> { where(comment_id: nil) }

  def root_comment
    comment.present? ? comment.root_comment : self
  end

  after_create :notify_post_author

  private

  def notify_post_author
    return if user == post.user

    Notification.create!(
      user: post.user,
      actor: user,
      notifiable: self,
      content: "Новый комментарий к вашей подборке",
      notification_type: "comment",
      read_status: false
    )
  end

end
