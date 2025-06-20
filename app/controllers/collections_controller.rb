class CollectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_collection, only: %i[show edit update destroy toggle_post toggle_item update_cover]
  before_action :authorize_user!, only: %i[edit update destroy toggle_post toggle_item update_cover]

  # AJAX-запрос для подгрузки коллекций пользователя
  def user_collections
    @collections = current_user.collections
    render json: @collections.as_json(only: [:id, :name, :image_url])
  end

  # GET /collections
  def index
    @default_collection = current_user.collections.find_by(default: true)
    @custom_collections = current_user.collections.where(default: false).order(updated_at: :desc)
  end

    # GET /collections/:id
  def show
    @collection = Collection.find(params[:id])
    @posts = @collection.posts.order(created_at: :desc)
    @items = @collection.items.order(created_at: :desc)
  end

  # POST /collections
  def create
    @collection = current_user.collections.new(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to collections_path, notice: "Коллекция успешно создана" }
        format.json { render json: { success: true, collection: @collection }, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @collection.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

def update
  if @collection.update(collection_params)
    respond_to do |format|
      format.html { redirect_to @collection, notice: 'Коллекция обновлена.' }
      format.json { head :ok } # для fetch-запросов
      format.turbo_stream # если используешь turbo
    end
  else
    respond_to do |format|
      format.html { render :edit }
      format.json { render json: { success: false, errors: @collection.errors.full_messages }, status: :unprocessable_entity }
    end
  end
end


  # DELETE /collections/:id
def destroy
  @collection.destroy!

  respond_to do |format|
    format.html { redirect_to collections_path, notice: "Коллекция успешно удалена." }
    format.json { render json: { success: true, message: "Коллекция успешно удалена." }, status: :ok }
  end
end


  def toggle_post
    post = Post.find(params[:post_id])
    default_collection = current_user.collections.find_by(default: true)

    if @collection.posts.include?(post)
      @collection.posts.delete(post)

      # 🧠 Если это кастомная коллекция — и больше нигде (кроме default) пост не сохранён:
      if !@collection.default?
        still_saved_elsewhere = current_user.collections
          .where.not(id: [@collection.id, default_collection&.id])
          .joins(:posts)
          .where(posts: { id: post.id })
          .exists?

        unless still_saved_elsewhere
          default_collection&.posts&.delete(post)
        end
      end

      update_collection_cover
      render json: { success: true, saved: false, message: "Пост удалён из коллекции." }

    else
      @collection.posts << post

      if !@collection.default? && default_collection && !default_collection.posts.exists?(post.id)
        default_collection.posts << post
      end

      update_collection_cover
      render json: { success: true, saved: true, message: "Пост добавлен в коллекцию." }
    end
  end

  def toggle_item
    item = Item.find(params[:item_id])
    default_collection = current_user.collections.find_by(default: true)

    if @collection.items.include?(item)
      @collection.items.delete(item)

      if !@collection.default?
        still_saved_elsewhere = current_user.collections
          .where.not(id: [@collection.id, default_collection&.id])
          .joins(:items)
          .where(items: { id: item.id })
          .exists?

        unless still_saved_elsewhere
          default_collection&.items&.delete(item)
        end
      end

      update_collection_cover
      render json: { success: true, saved: false, message: "Предмет удалён из коллекции." }

    else
      @collection.items << item

      if !@collection.default? && default_collection && !default_collection.items.exists?(item.id)
        default_collection.items << item
      end

      update_collection_cover
      render json: { success: true, saved: true, message: "Предмет добавлен в коллекцию." }
    end
  end

  def update_cover
    if params[:image_url].present?
      @collection.set_custom_cover(params[:image_url])
      render json: { success: true, message: "Обложка коллекции обновлена.", image_url: @collection.image_url }
    else
      render json: { success: false, error: "Необходимо передать изображение." }, status: :unprocessable_entity
    end
  end

  private

  def set_collection
    @collection = current_user.collections.find_by(id: params[:id])
    unless @collection
      render json: { success: false, error: "Коллекция не найдена или у вас нет доступа." }, status: :not_found
    end
  end

  def collection_params
    params.require(:collection).permit(:title, :image_url, :private)
  end

  def authorize_user!
    unless @collection.user_id == current_user.id
      render json: { success: false, error: "У вас нет прав на изменение этой коллекции." }, status: :forbidden
    end
  end

  def update_collection_cover
    return if @collection.image_url.to_s.strip.present? && !@collection.default?
    @collection.image_url = @collection.cover_image_url
    @collection.save! if @collection.changed?
  end
end
