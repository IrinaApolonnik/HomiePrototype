module Api
    module V1
      class ApplicationController < ActionController::API
        # Не использовать CSRF токены в API
        include ActionController::RequestForgeryProtection
        protect_from_forgery with: :null_session
      end
    end
  end