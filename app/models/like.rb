class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  after_create :create_notification

  private

  def create_notification
    return if user == likeable.user

    Notification.create!(
      user: likeable.user,
      actor: user,
      notifiable: likeable, # важно!
      content: "Ваша #{likeable_type == 'Post' ? 'подборка' : 'запись'} получила лайк!",
      notification_type: "like",
      read_status: false
    )
  end
end
