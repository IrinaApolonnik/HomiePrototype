class PostsController < ApplicationController
    load_and_authorize_resource

    # Для страницы с подбоками
    def index
        if current_user && current_user.admin?
            # Администратор видит все посты
            @posts = Post.all
        elsif current_user
            # Авторизованные пользователи видят только свои посты
            @posts = current_user.posts
        else
            # Гости видят только публичные посты
            @posts = Post.where(public: true)
        end
    end
    
    # Для страниц с единичной подборкой
    def show
        @post = Post.find(params[:id])
        @comments = @post.comments
    end

    # Для страницы создания
    def new
        @post = Post.new
    end

    # Для страницы редактирования
    def edit
    end
    def create
        #post_params.merge(post: {user_id: current_user.id})
        @post = current_user.posts.new(post_params)
    
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
    
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_post
          @post = Post.find(params[:id])
        end
    
        # Only allow a list of trusted parameters through.
        def post_params
          params.require(:post).permit(:title, :description, :image_url)
        end
end