class NotificationsController < ApplicationController
    before_action :authenticate_user!

    def index
        @unread_notifications = current_user.notifications.where(read_status: false).order(created_at: :desc)
        @read_notifications = current_user.notifications.where(read_status: true).order(created_at: :desc)
    end

    def mark_all_as_read
        current_user.notifications.where(read_status: false).update_all(read_status: true)
        head :ok
    end
end
