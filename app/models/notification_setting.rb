# app/models/notification_setting.rb
class NotificationSetting < ApplicationRecord
  belongs_to :user

  TYPES = %w[
    like
    comment
    follow
    new_post
  ].freeze
end
