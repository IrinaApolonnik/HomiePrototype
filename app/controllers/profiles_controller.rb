class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: %i[show index]
  before_action :set_profile, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]
  before_action :authorize_admin!, only: %i[index destroy]

  # GET /profiles
  def index
    @profiles = Profile.all
  end

  # GET /profiles/:id
  def show
    @posts = @profile.posts.includes(:likes)
    @items = @profile.items

    # Проверяем параметр sort, если нет - берем дефолтное "new"
    sort_param = params[:sort].presence || "new"
    Rails.logger.debug "SORT PARAM: #{sort_param}" # Логируем параметр сортировки


    # Если params[:sort] нет, но есть сохранённое значение в localStorage, используем его
    if params[:sort].blank? && cookies[:selectedSort].present?
      sort_param = cookies[:selectedSort]
    end

    # Применяем сортировку
    case sort_param
    when "popular"
      @posts = @posts.order(likes_count: :desc) # По популярности
    when "new"
      @posts = @posts.order(created_at: :desc) # Новые в начале (по умолчанию)
      @items = @items.order(created_at: :desc)
    when "old"
      @posts = @posts.order(created_at: :asc)
      @items = @items.order(created_at: :asc)  # Старые в начале
    end

    # Сохраняем выбранный параметр в cookie, чтобы учитывать его при следующих загрузках
    cookies[:selectedSort] = sort_param

    respond_to do |format|
      format.html
      format.js
    end
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
  def edit; 
    @profile = current_user.profile
  end

  # PATCH/PUT /profiles/:id
  def update
    @profile = current_user.profile
    if @profile.update(profile_params)
      redirect_to root_path, notice: "Профиль обновлён!"
    else
      render :edit, alert: "Ошибка при обновлении профиля."
    end
  end

  # DELETE /profiles/:id
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