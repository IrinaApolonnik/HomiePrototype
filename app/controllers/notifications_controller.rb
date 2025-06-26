class NotificationsController < ApplicationController
  # Требуется авторизация пользователя
  before_action :authenticate_user!

  # Главная страница уведомлений
  def index
    # Непрочитанные уведомления (сортировка от новых к старым)
    @unread_notifications = current_user.notifications
                                        .where(read_status: false)
                                        .order(created_at: :desc)

    # Прочитанные уведомления
    @read_notifications = current_user.notifications
                                      .where(read_status: true)
                                      .order(created_at: :desc)
  end

  # Пометить все уведомления как прочитанные
  def mark_all_as_read
    current_user.notifications.where(read_status: false).update_all(read_status: true)
    head :ok # Возвращает 200 без контента
  end
end
