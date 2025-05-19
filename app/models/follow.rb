class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validates :follower_id, uniqueness: { scope: :followed_id, message: "Уже подписан" }
  validate :prevent_self_follow

  private

  def prevent_self_follow
    errors.add(:follower_id, "Нельзя подписаться на себя") if follower_id == followed_id
  end
end
