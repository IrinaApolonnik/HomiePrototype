class ApplicationController < ActionController::Base

  # Ограничение доступа только для современных браузеров 
  # (поддержка webp, web push, import maps, CSS nesting, :has и т.д.)
  allow_browser versions: :modern

  # Обработка ошибки доступа (например, при запрете действия через CanCanCan)
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }                              # Возвращаем 403 для JSON-запросов
      format.html { redirect_to root_path, alert: exception.message } # Перенаправляем на главную с сообщением
    end
  end

  # Выполняем перед каждым действием
  before_action :set_random_tags

  # Устанавливаем случайные теги для отображения, например, в футере или боковом меню
  def set_random_tags
    @random_tags = ActsAsTaggableOn::Tag.order("RANDOM()").limit(6)
  end

  # Отключаем CSRF-защиту для API-запросов (или других случаев, когда нужен null_session)
  protect_from_forgery with: :null_session 

end
