class LikesController < ApplicationController
  # Требуем авторизацию пользователя перед любыми действиями
  before_action :authenticate_user!

  # Метод для переключения лайка (лайк/анлайк)
  def toggle
    likeable = find_likeable

    if likeable.nil?
      render json: { error: "Resource not found" }, status: :not_found
      return
    end

    # Ищем существующий лайк пользователя
    like = likeable.likes.find_by(user_id: current_user.id)

    if like
      # Удаляем лайк (анлайк)
      like.destroy!
      render json: {
        likes_count: likeable.likes.count,
        liked: false
      }, status: :ok
    else
      # Ставим лайк
      likeable.likes.create!(user_id: current_user.id)
      render json: {
        likes_count: likeable.likes.count,
        liked: true
      }, status: :ok
    end

  rescue ActiveRecord::RecordInvalid => e
    # Ошибка при создании лайка
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  # Метод для получения лайкаемого объекта (например, Post или Comment)
  # Через параметры: type (модель) и id (объект)
  def find_likeable
    klass = params[:type].safe_constantize # Преобразуем строку в класс
    klass&.find_by(id: params[:id])        # Ищем объект
  rescue NameError
    nil
  end
end
