class PostsController < ApplicationController
  load_and_authorize_resource

  # Для страницы с подборками
  def index
    if user_signed_in? && current_user.admin?
      # Администратор видит все посты
      @posts = Post.all
    elsif user_signed_in?
      # Авторизованные пользователи видят свои и публичные посты
      @posts = Post.where(public: true).or(Post.where(profile: current_user.profile))
    else
      # Гости видят только публичные посты
      @posts = Post.where(public: true)
    end
  
    @popular_posts = Post.left_joins(:likes)
                         .where(public: true)
                         .group(:id)
                         .order('COUNT(likes.id) DESC')
                         .limit(12) # Общее количество популярных постов
  end
  
  def by_tag
    @posts = Post.tagged_with(params[:tag])
    render :index
  end

  def my_posts
    @posts = current_profile.posts
    @liked_posts = Post.joins(:likes).where(likes: { profile_id: current_profile.id })
  end

  # Для страниц с единичной подборкой
  def show
    @post = Post.find(params[:id])
    @profile = @post.profile
  end

  # Для страницы создания
  def new
    @post = Post.new
  end

  # Для страницы редактирования
  def edit
  end

  def create
    @post = current_profile.posts.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
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
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
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
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
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

    redirect_to @post
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :description, :image_url, :tag_list, :public)
  end
end