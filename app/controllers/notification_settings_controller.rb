class NotificationSettingsController < ApplicationController
  before_action :authenticate_user!

  def update
    permitted_types = %w[like comment follow new_post]
    settings_params = params.fetch(:notification_settings, {})

    permitted_types.each do |type|
      setting = current_user.notification_settings.find_or_initialize_by(notification_type: type)
      setting.enabled = settings_params.key?(type)
      setting.save!
    end

    redirect_to request.referer || settings_path(tab: "notifications"), notice: "Настройки уведомлений обновлены"

  rescue => e
    redirect_to request.referer || settings_path(tab: "notifications"), alert: "Ошибка при обновлении: #{e.message}"

  end
end
