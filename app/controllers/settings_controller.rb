class SettingsController < ApplicationController
  before_action :authenticate_user!

  def load_tab
    case params[:tab]
    when "profile"
      render partial: "settings/profile"
    when "security"
      render partial: "settings/security"
    when "notifications"
      @user = current_user
      ensure_notification_settings(@user)
      render partial: "settings/notifications"
    when "preferences"
      render partial: "settings/preferences"
    else
      render plain: "Раздел не найден", status: :not_found
    end
  end


  private

def ensure_notification_settings(user)
  default_types = %w[like comment follow new_post]
  existing_types = user.notification_settings.pluck(:notification_type)

  (default_types - existing_types).each do |type|
    user.notification_settings.create!(notification_type: type, enabled: true)
  end
end
end