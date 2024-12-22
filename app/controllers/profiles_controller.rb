class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: %i[show edit update destroy]
  before_action :authorize_admin!, only: %i[index destroy]

  # GET /profiles
  # Только для администратора
  def index
    @profiles = Profile.all
  end

  # GET /profiles/:id
  # Просмотр профиля текущего пользователя или других пользователей
  def show
    if @profile.nil?
      redirect_to profile_path(current_user.profile), alert: "Профиль не найден."
    end
  end

  # GET /profiles/new
  # Создание профиля для текущего пользователя
  def new
    @profile = current_user.build_profile
  end

  # POST /profiles
  # Создание профиля текущего пользователя
  def create
    @profile = current_user.profile || current_user.build_profile
  
    respond_to do |format|
      if @profile.update(profile_params) # Используем update вместо save для обновления или создания
        format.html { redirect_to my_posts_posts_path, notice: "Профиль успешно обновлен." }
        format.json { render json: { success: true }, status: :ok }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # GET /profiles/:id/edit
  # Редактирование профиля текущим пользователем
  def edit
  end

  # PATCH/PUT /profiles/:id
  # Обновление профиля текущим пользователем
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to my_posts_posts_path, notice: "Профиль успешно обновлен." }
        format.json { render json: { success: true }, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/:id
  # Удаление профиля (только администратор)
  def destroy
    @profile.destroy!
    respond_to do |format|
      format.html { redirect_to profiles_path, status: :see_other, notice: "Профиль успешно удален." }
      format.json { render json: { success: true }, status: :ok }
    end
  end

  private

  # Устанавливаем профиль
  def set_profile
    @profile = Profile.find_by(id: params[:id]) || current_user.profile

    # Проверка: если профиль не принадлежит текущему пользователю или администратору
    unless @profile && (@profile.user == current_user || current_user.admin?)
      redirect_to my_posts_posts_path, alert: "Вы не можете просматривать этот профиль."
    end
  end

  # Разрешенные параметры
  def profile_params
    params.require(:profile).permit(:name, :bio, :avatar, :username)
  end

  # Проверка административных прав
  def authorize_admin!
    redirect_to root_path, alert: "У вас нет прав для выполнения этого действия." unless current_user.admin?
  end
end