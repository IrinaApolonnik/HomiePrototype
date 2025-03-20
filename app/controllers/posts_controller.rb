class PostsController < ApplicationController
  load_and_authorize_resource

  # Для страницы с подборками
  def index
    # Проверяем параметр sort, если нет - берем дефолтное "new"
    sort_param = params[:sort].presence || "new"
    Rails.logger.debug "SORT PARAM: #{sort_param}" # Логируем параметр сортировки

    # Загружаем посты в зависимости от статуса пользователя
    @posts = if current_user&.admin?
               Post.includes(:likes, :profile).all
             elsif user_signed_in?
               Post.includes(:likes, :profile)
                   .where(public: true)
                   .or(Post.where(profile: current_user.profile))
             else
               Post.includes(:likes, :profile).where(public: true)
             end

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
    when "old"
      @posts = @posts.order(created_at: :asc)  # Старые в начале
    end

    # Сохраняем выбранный параметр в cookie, чтобы учитывать его при следующих загрузках
    cookies[:selectedSort] = sort_param

    respond_to do |format|
      format.html
      format.js
    end
  end

  def by_tag
    if params[:tags].present?
      selected_tags = params[:tags].split(",")
  
      # Ищем посты с хотя бы одним тегом
      posts_with_tags = Post.tagged_with(selected_tags, any: true).includes(:likes, :profile)
  
      # Сортируем: сначала посты с наибольшим числом совпавших тегов
      @posts = posts_with_tags.sort_by { |post| -post.tags.where(name: selected_tags).count }
  
    else
      @posts = Post.includes(:likes, :profile) # Если теги не выбраны, показываем всё
    end
  
    render :index
  end


  # Для страниц с единичной подборкой
  def show; 
  @post = Post.find(params[:id])

  end

  # Для страницы создания
  def new; end

  # Для страницы редактирования
  def edit; end

  def create
    @post.profile = current_profile

    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Пост был успешно создан!" }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Пост был успешно обновлён!" }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Пост был успешно удалён!" }
      format.json { head :no_content }
    end
  end

  def like
    like = @post.likes.find_by(profile_id: current_profile.id)

    if like
      like.destroy!
    else
      @post.likes.create(profile_id: current_profile.id)
    end

    respond_to do |format|
      format.html { redirect_to @post }
      format.json { render json: { liked: like.nil? }, status: :ok }
    end
  end


  private

  def post_params
    if params[:post][:tag_list].is_a?(String)
      params[:post][:tag_list] = params[:post][:tag_list].split(',')
    end
    params.require(:post).permit(:title, :description, :image_url, tag_list: [])
  end
end