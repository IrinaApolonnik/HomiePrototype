class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :like]

  def index
    unless user_signed_in?
      return render :guest_home
    end

    sort_param = params[:sort].presence || "new"
    Rails.logger.debug "SORT PARAM: #{sort_param}"

    @posts = if current_user&.admin?
               Post.includes(:likes, :user).all
             else
               Post.includes(:likes, :user)
                   .where(public: true)
                   .or(Post.where(user: current_user))
             end

    if params[:sort].blank? && cookies[:selectedSort].present?
      sort_param = cookies[:selectedSort]
    end

    case sort_param
    when "popular"
      @posts = @posts.order(likes_count: :desc)
    when "new"
      @posts = @posts.order(created_at: :desc)
    when "old"
      @posts = @posts.order(created_at: :asc)
    end

    cookies[:selectedSort] = sort_param

    respond_to do |format|
      format.html
      format.js
    end
  end

  def by_tag
    if params[:tags].present?
      selected_tags = params[:tags].split(",")
      posts_with_tags = Post.tagged_with(selected_tags, any: true).includes(:likes, :user)
      @posts = posts_with_tags.sort_by { |post| -post.tags.where(name: selected_tags).count }
    else
      @posts = Post.includes(:likes, :user)
    end

    render :index
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
    authorize! :update, @post

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