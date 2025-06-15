class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_profile, only: %i[show]
  before_action :authorize_admin!, only: %i[index]

  # GET /profiles
  def index
    @profiles = Profile.all
  end
def suggestions
  suggested_profiles = Profile.where.not(user_id: current_user.id)
                              .order("RANDOM()")
                              .limit(8)

  render partial: "posts/suggestions", locals: { suggested_profiles: suggested_profiles }, layout: false

end


  # GET /profiles/:id
  def show
    @posts = @profile.user.posts.includes(:likes)
    @items = @profile.user.items

    sort_param = params[:sort].presence || "new"
    if params[:sort].blank? && cookies[:selectedSort].present?
      sort_param = cookies[:selectedSort]
    end

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

    cookies[:selectedSort] = sort_param
  end

  # GET /profile/edit
  def edit
    @profile = current_user.profile
  end

  # PATCH/PUT /profile
def update
  @profile = current_user.profile
  if @profile.update(profile_params)
    respond_to do |format|
      format.html do
        redirect_to root_path, notice: "Профиль обновлён!"
      end

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

  # Устанавливаем профиль для просмотра
  def set_profile
    @profile = Profile.find_by(id: params[:id])
    redirect_to root_path, alert: "Профиль не найден." unless @profile
  end

  # Проверка прав администратора
  def authorize_admin!
    redirect_to root_path, alert: "У вас нет прав для выполнения этого действия." unless current_user&.admin?
  end

  # Разрешённые параметры
  def profile_params
    params.require(:profile).permit(:name, :bio, :avatar_url, :username)
  end
end