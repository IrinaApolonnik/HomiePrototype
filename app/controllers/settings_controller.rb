class SettingsController < ApplicationController
  before_action :authenticate_user!

  def load_tab
    case params[:tab]
    when "profile"
      render partial: "settings/profile"
    when "security"
      render partial: "settings/security"
    when "notifications"
      render partial: "settings/notifications"
    when "preferences"
      render partial: "settings/preferences"
    else
      render plain: "Раздел не найден", status: :not_found
    end
  end
end