class CommentsController < ApplicationController
  load_and_authorize_resource :post
  load_and_authorize_resource through: :post

  before_action :set_post, only: [:create, :destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.profile = current_profile # Присваиваем профиль текущего пользователя

    if params[:parent_comment_id].present?
      parent = @post.comments.find_by(id: params[:parent_comment_id])
    
      unless parent
        redirect_to post_path(@post), alert: 'Родительский комментарий не найден.' and return
      end
    
      @comment.comment = parent.root_comment
    end

    if @comment.save
      redirect_to post_path(@post), notice: 'Комментарий успешно создан.'
    else
      redirect_to post_path(@post), alert: 'Не удалось создать комментарий.'
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post), notice: 'Комментарий успешно удалён.'
  end
  def like
    like = @comment.likes.find_by(profile_id: current_profile.id)

    if like
      like.destroy!
    else
      @comment.likes.create(profile_id: current_profile.id)
    end

    respond_to do |format|
      format.html { redirect_to @comment }
      format.json { render json: { liked: like.nil? }, status: :ok }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body) # Разрешённые параметры
  end
end