class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_profile, only: %i[show edit update destroy]
  before_action :authorize_admin!, only: %i[index destroy]

  # GET /profiles
  # Только для администратора
  def index
    @profiles = Profile.all
  end

  # GET /profiles/:id
  # Просмотр профиля
  def show
    @profile = Profile.find(params[:id])
    @posts = @profile.posts.order(created_at: :desc)
    @liked_posts = Post.joins(:likes).where(likes: { profile_id: @profile.id })
  end

  # GET /profiles/new
  def new
    @profile = current_user.build_profile
  end

  # POST /profiles
  def create
    @profile = current_user.profile || current_user.build_profile

    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Профиль успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /profiles/:id/edit
  def edit
    return head :forbidden unless @profile.user == current_user
  end

  # PATCH/PUT /profiles/:id
  def update
    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Профиль успешно обновлен."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /profiles/:id
  def destroy
    @profile.destroy!
    redirect_to profiles_path, notice: "Профиль успешно удален."
  end

  private

  # Устанавливаем профиль
  def set_profile
    @profile = Profile.find_by(id: params[:id])

    unless @profile
      redirect_to root_path, alert: "Профиль не найден."
    end
  end

  # Разрешенные параметры
  def profile_params
    params.require(:profile).permit(:name, :bio, :avatar_url, :username)
  end

  # Проверка административных прав
  def authorize_admin!
    redirect_to root_path, alert: "У вас нет прав для выполнения этого действия." unless current_user.admin?
  end
end