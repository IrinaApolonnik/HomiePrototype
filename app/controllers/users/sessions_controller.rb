class Users::SessionsController < Devise::SessionsController
    layout "auth" # Кастомный лейаут для логина
  
    # Поведение после успешного входа
    protected
    def after_sign_in_path_for(resource)
      root_path 
    end
  
    # Маршрут после выхода
    def after_sign_out_path_for(resource_or_scope)
        root_path 
    end
  end