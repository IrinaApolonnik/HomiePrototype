class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: %i[show edit update destroy]
  before_action :authorize_admin!, except: %i[index show]

  # GET /profiles
  # Администратор или публичный доступ к списку всех профилей
  def index
    @profiles = Profile.all
  end

  # GET /profiles/1
  # Просмотр профиля (доступен всем)
  def show
  end

  # GET /profiles/new
  # Только для администратора
  def new
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  # Только для администратора
  def edit
  end

  # POST /profiles
  # Создание профиля (только администратор)
  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      redirect_to @profile, notice: "Профиль успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /profiles/1
  # Обновление профиля (только администратор)
  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: "Профиль успешно обновлен."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /profiles/1
  # Удаление профиля (только администратор)
  def destroy
    @profile.destroy!
    redirect_to profiles_path, status: :see_other, notice: "Профиль успешно удален."
  end

  private

  # Поиск профиля
  def set_profile
    @profile = Profile.find(params[:id])
  end

  # Разрешенные параметры
  def profile_params
    params.require(:profile).permit(:user_id, :name, :bio, :avatar)
  end

  # Проверка административных прав
  def authorize_admin!
    redirect_to root_path, alert: "У вас нет прав для выполнения этого действия." unless current_user.admin?
  end
end