class Notification < ApplicationRecord
  belongs_to :user                          # получатель уведомления
  belongs_to :actor, polymorphic: true      # инициатор действия
  belongs_to :notifiable, polymorphic: true # объект действия (лайк, комментарий, пост и т.д.)
  
  attribute :read_status, :boolean, default: false

  scope :unread, -> { where(read_status: false) }

  def mark_as_read!
    update(read_status: true)
  end
end
