class CommentsController < ApplicationController
  # Авторизация доступа к посту и комментариям через CanCanCan
  load_and_authorize_resource :post
  load_and_authorize_resource through: :post

  # Устанавливаем пост для экшенов create и destroy
  before_action :set_post, only: [:create, :destroy]

  # Создание комментария к посту
  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user # Присваиваем текущего пользователя

    # Если это ответ на другой комментарий
    if params[:parent_comment_id].present?
      parent = @post.comments.find_by(id: params[:parent_comment_id])
      
      # Проверка: существует ли родительский комментарий
      unless parent
        redirect_to post_path(@post), alert: 'Родительский комментарий не найден.' and return
      end

      # Устанавливаем связь с корневым комментарием (для плоской вложенности)
      @comment.comment = parent.root_comment
    end

    # Сохраняем комментарий
    if @comment.save
      redirect_to post_path(@post), notice: 'Комментарий успешно создан.'
    else
      redirect_to post_path(@post), alert: 'Не удалось создать комментарий.'
    end
  end

  # Удаление комментария
  def destroy
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post), notice: 'Комментарий успешно удалён.'
  end

  # Лайк/дизлайк комментария (AJAX-обработка)
  def like
    like = @comment.likes.find_by(user_id: current_user.id)

    if like
      like.destroy! # Удаляем лайк, если уже поставлен
    else
      @comment.likes.create(user_id: current_user.id) # Ставим лайк
    end

    respond_to do |format|
      format.html { redirect_to @comment }
      format.json { render json: { liked: like.nil? }, status: :ok }
    end
  end

  private

  # Поиск поста по параметру post_id
  def set_post
    @post = Post.find(params[:post_id])
  end

  # Разрешённые параметры комментария
  def comment_params
    params.require(:comment).permit(:body)
  end
end
