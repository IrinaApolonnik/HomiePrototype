class CommentsController < ApplicationController
  load_and_authorize_resource

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user # Присваиваем текущего пользователя комментарию

    if @comment.save
      redirect_to post_path(@post), notice: 'Комментарий успешно создан.'
    else
      redirect_to post_path(@post), alert: 'Не удалось создать комментарий.'
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    if can?(:destroy, @comment)
      @comment.destroy
      redirect_to post_path(@post), notice: 'Комментарий успешно удалён.'
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body) # Убираем commenter, так как он связан с пользователем
  end
end