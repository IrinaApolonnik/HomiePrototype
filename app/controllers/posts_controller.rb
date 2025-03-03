class PostsController < ApplicationController
  load_and_authorize_resource

  # Для страницы с подборками
  def index
    @posts = if current_user&.admin?
               Post.includes(:likes, :profile).all
             elsif user_signed_in?
               Post.includes(:likes, :profile)
                   .where(public: true)
                   .or(Post.where(profile: current_user.profile))
             else
               Post.includes(:likes, :profile).where(public: true)
             end

    @popular_posts = Post.left_joins(:likes)
                         .where(public: true)
                         .group(:id)
                         .order('COUNT(likes.id) DESC')
                         .limit(12)
  end

  def by_tag
    @posts = Post.tagged_with(params[:tag]).includes(:likes, :profile)
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