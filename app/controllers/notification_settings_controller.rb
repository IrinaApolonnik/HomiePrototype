class NotificationSettingsController < ApplicationController
  # Требуется авторизация перед обновлением
  before_action :authenticate_user!

  # Обновление настроек уведомлений
  def update
    # Разрешённые типы уведомлений (белый список)
    permitted_types = %w[like comment follow new_post]

    # Получаем параметры настроек из формы
    settings_params = params.fetch(:notification_settings, {})

    # Обновляем каждую настройку по типу уведомления
    permitted_types.each do |type|
      # Ищем или создаём запись настройки по типу
      setting = current_user.notification_settings.find_or_initialize_by(notification_type: type)

      # Если ключ есть в переданных параметрах — включаем, иначе выключаем
      setting.enabled = settings_params.key?(type)
      setting.save!
    end

    # Возврат назад с сообщением об успехе
    redirect_to request.referer || settings_path(tab: "notifications"),
      notice: "Настройки уведомлений обновлены"

  rescue => e
    # В случае ошибки — возвращаем с сообщением об ошибке
    redirect_to request.referer || settings_path(tab: "notifications"),
      alert: "Ошибка при обновлении: #{e.message}"
  end
end
