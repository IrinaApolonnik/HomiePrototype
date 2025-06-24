class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :notification_type, presence: true
end
