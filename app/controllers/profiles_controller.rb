class ProfilesController < ApplicationController
  # Требуем авторизацию для всех действий, кроме просмотра профиля
  before_action :authenticate_user!, except: %i[show]

  # Устанавливаем профиль по ID (для show)
  before_action :set_profile, only: %i[show]

  # Проверка прав администратора для index
  before_action :authorize_admin!, only: %i[index]

  # GET /profiles — админская страница со всеми профилями
  def index
    @profiles = Profile.all
  end

  # GET /suggestions — случайные профили для блока "рекомендации"
  def suggestions
    suggested_profiles = Profile.where.not(user_id: current_user.id)
                                .order("RANDOM()")
                                .limit(8)

    render partial: "posts/suggestions",
           locals: { suggested_profiles: suggested_profiles },
           layout: false
  end

  # GET /profiles/:id — просмотр чужого профиля
  def show
    @posts = @profile.user.posts.includes(:likes)
    @items = @profile.user.items

    # --- Сортировка контента ---
    sort_param = params[:sort].presence || "new"
    sort_param = cookies[:selectedSort] if params[:sort].blank? && cookies[:selectedSort].present?

    case sort_param
    when "popular"
      @posts = @posts.order(likes_count: :desc)
    when "new"
      @posts = @posts.order(created_at: :desc)
      @items = @items.order(created_at: :desc)
    when "old"
      @posts = @posts.order(created_at: :asc)
      @items = @items.order(created_at: :asc)
    end

    # Сохраняем выбор в cookies
    cookies[:selectedSort] = sort_param
  end

  # GET /profile/edit — форма редактирования текущего профиля
  def edit
    @profile = current_user.profile
  end

  # PATCH/PUT /profile — обновление профиля текущего пользователя
  def update
    @profile = current_user.profile

    if @profile.update(profile_params)
      respond_to do |format|
        format.html do
          redirect_to root_path, notice: "Профиль обновлён!"
        end

        # Обновление через JS (например, из модалки)
        format.js do
          render js: "window.location.href = '/?notice=#{CGI.escape('Профиль обновлён!')}';"
        end
      end
    else
      respond_to do |format|
        format.html do
          render :edit, alert: "Ошибка при обновлении профиля."
        end

        format.js do
          render js: "showFlashAlert('Ошибка при обновлении профиля.');"
        end
      end
    end
  end

  private

  # Устанавливаем профиль для show
  def set_profile
    @profile = Profile.find_by(id: params[:id])
    redirect_to root_path, alert: "Профиль не найден." unless @profile
  end

  # Проверка, что текущий пользователь — админ
  def authorize_admin!
    redirect_to root_path, alert: "У вас нет прав для выполнения этого действия." unless current_user&.admin?
  end

  # Разрешённые параметры профиля
  def profile_params
    params.require(:profile).permit(:name, :bio, :avatar_url, :username)
  end
end
