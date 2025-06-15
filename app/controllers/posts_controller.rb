class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :like]

def index
  return render :guest_home unless user_signed_in?

  # Сортировка
  sort_param = params[:sort].presence || cookies[:selectedSort] || "new"
  cookies[:selectedSort] = sort_param

  # Фильтр: all или following
  filter_param = params[:filter].presence || cookies[:feedFilter] || "all"
  cookies[:feedFilter] = filter_param

  # Начинаем с нужных постов (все публичные + свои)
  base_scope = if current_user.admin?
               Post.includes(:likes, :user)
             else
               Post.includes(:likes, :user)
                   .where(public: true)
                   .or(Post.where(user: current_user))
             end

  # Фильтрация по подпискам
  
@filter_param = filter_param
@following_empty = false

if filter_param == "following"
  followed_ids = current_user.followed_users.select(:id)
  @following_empty = followed_ids.empty?
  base_scope = base_scope.where(user_id: followed_ids)
end

@posts = base_scope

  # Фильтрация по тегам (через joins чтобы остаться relation'ом)
if params[:tags].present?
  tags = params[:tags].split(",")

  base_scope = base_scope
    .joins(:tags)
    .where(tags: { name: tags })
    .select('posts.*, COUNT(tags.id) AS tag_match_count')
    .group('posts.id')
    .order('tag_match_count DESC')
end


  # Сортировка
  base_scope = case sort_param
               when "popular"
                 base_scope.order(likes_count: :desc)
               when "old"
                 base_scope.order(created_at: :asc)
               else
                 base_scope.order(created_at: :desc)
               end

  # Eager load
  @posts = base_scope.includes(:user, :likes)

  respond_to do |format|
    format.html
    format.js
  end
end






  def show
    authorize! :read, @post
  end

  def new
    authorize! :create, Post
    @post = Post.new
  end

  def edit
    authorize! :update, @post
  end

  def create
    authorize! :create, Post
    post_attrs = post_params.except(:temp_items_json)
    @post = Post.new(post_attrs)
    @post.user = current_user

    respond_to do |format|
      ActiveRecord::Base.transaction do
        if @post.save
          temp_items = JSON.parse(params[:post][:temp_items_json] || "[]")

          if temp_items.empty?
            raise ActiveRecord::Rollback, "Пост не может быть создан без товаров"
          end

          temp_items.each do |item_data|
            @post.items.create!(
              name:         item_data["name"],
              purchase_url: item_data["purchase_url"],
              price:        item_data["price"],
              image_url:    item_data["image_url"],
              user:        current_user
            )
          end

          format.html { redirect_to post_url(@post), notice: "Пост был успешно создан!" }
          format.json { render :show, status: :created, location: @post }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end
  rescue => e
    Rails.logger.error("Ошибка при создании поста: #{e.message}")
    flash.now[:alert] = "Не удалось создать пост"
    render :new, status: :unprocessable_entity
  end

def update
  @post = Post.find(params[:id])
  temp_items_data = JSON.parse(post_params[:temp_items_json]) rescue []

  if @post.update(post_params.except(:temp_items_json))
    # Удаляем удалённые товары
    current_item_ids = temp_items_data.map { |i| i["id"] }.compact
    @post.items.where.not(id: current_item_ids).destroy_all

    # Обновляем существующие или создаём новые
    temp_items_data.each do |item_data|
      item = @post.items.find_or_initialize_by(id: item_data["id"])
      item.assign_attributes(
        name: item_data["name"],
        price: item_data["price"],
        purchase_url: item_data["purchase_url"],
        image_url: item_data["image_url"]
      )
      item.save
    end

    redirect_to @post, notice: "Пост обновлён"
  else
    render :edit, status: :unprocessable_entity
  end
end






  def destroy
    authorize! :destroy, @post
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Пост был успешно удалён!" }
      format.json { head :no_content }
    end
  end

  def like
    authorize! :like, @post

    like = @post.likes.find_by(user_id: current_user.id)

    if like
      like.destroy!
    else
      @post.likes.create(user_id: current_user.id)
    end

    respond_to do |format|
      format.html { redirect_to @post }
      format.json { render json: { liked: like.nil? }, status: :ok }
    end
  end

  private

  def set_post
    @post = Post.find_by(id: params[:id])
    unless @post
      redirect_to posts_path, alert: "Пост не найден" and return
    end
  end

  def post_params
    if params[:post][:tag_list].is_a?(String)
      params[:post][:tag_list] = params[:post][:tag_list].split(',')
    end

    params.require(:post).permit(:title, :description, :image_url, :temp_items_json, tag_list: [])
  end
end