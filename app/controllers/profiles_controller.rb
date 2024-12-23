class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: %i[show index]
  before_action :set_profile, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]
  before_action :authorize_admin!, only: %i[index destroy]

  # GET /profiles
  # Любой пользователь может видеть список профилей
  def index
    @profiles = Profile.all
  end

  # GET /profiles/:id
  # Просмотр конкретного профиля доступен всем
  def show
    @posts = @profile.posts.order(created_at: :desc)
    @liked_posts = Post.joins(:likes).where(likes: { profile_id: @profile.id })
  end

  # GET /profiles/new
  # Создание нового профиля доступно авторизованному пользователю
  def new
    @profile = current_user.build_profile
  end

  # POST /profiles
  # Создание профиля
  def create
    @profile = current_user.profile || current_user.build_profile

    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Профиль успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /profiles/:id/edit
  # Пользователь может редактировать только свой профиль
  def edit; end

  # PATCH/PUT /profiles/:id
  # Обновление профиля
  def update
    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Профиль успешно обновлен."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /profiles/:id
  # Удаление профиля
  def destroy
    if @profile.user != current_user && !current_user.admin?
      return redirect_to root_path, alert: "У вас нет прав на удаление этого профиля."
    end

    if Profile.where(user: @profile.user).count == 1
      return redirect_to root_path, alert: "Нельзя удалить единственный профиль пользователя."
    end

    @profile.destroy
    redirect_to current_user.admin? ? profiles_path : root_path, notice: "Профиль успешно удален."
  end

  private

  # Устанавливаем профиль
  def set_profile
    @profile = Profile.find_by(id: params[:id])
    redirect_to root_path, alert: "Профиль не найден." unless @profile
  end

  # Проверяем права пользователя
  def authorize_user!
    unless @profile.user == current_user || current_user.admin?
      redirect_to root_path, alert: "У вас нет прав на выполнение этого действия."
    end
  end

  # Проверка прав администратора
  def authorize_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "У вас нет прав для выполнения этого действия."
    end
  end

  # Разрешённые параметры
  def profile_params
    params.require(:profile).permit(:name, :bio, :avatar_url, :username)
  end
end