class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validates :follower_id, uniqueness: { scope: :followed_id, message: "Уже подписан" }
  validate :prevent_self_follow
  
  after_create :notify_user_of_new_follower

  private

  def prevent_self_follow
    errors.add(:follower_id, "Нельзя подписаться на себя") if follower_id == followed_id
  end

  def notify_user_of_new_follower
    follower_user = User.find(self.follower_id)
    followed_user = User.find(self.followed_id)

    Notification.create!(
      user: followed_user,
      actor: follower_user,
      notifiable: self,
      notification_type: "follow",
      content: "#{follower_user.profile.username} подписался на вас",
      read_status: false 
    )
  end

end


