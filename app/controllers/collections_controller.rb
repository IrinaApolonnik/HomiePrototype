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
  def show; end

  # POST /collections
  def create
    @collection = current_user.collections.new(collection_params)

    if @collection.save
      render json: { success: true, collection: @collection }, status: :created
    else
      render json: { success: false, errors: @collection.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /collections/:id
  def update
    if @collection.update(collection_params)
      render json: { success: true, collection: @collection }, status: :ok
    else
      render json: { success: false, errors: @collection.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /collections/:id
  def destroy
    @collection.destroy!
    render json: { success: true, message: "Коллекция успешно удалена." }, status: :ok
  end

  def toggle_post
    post = Post.find(params[:post_id])
    if @collection.posts.include?(post)
      @collection.posts.delete(post)
      update_collection_cover
      render json: { success: true, saved: false, message: "Пост удалён из коллекции." }
    else
      @collection.posts << post
      update_collection_cover
      render json: { success: true, saved: true, message: "Пост добавлен в коллекцию." }
    end
  end

  def toggle_item
    item = Item.find(params[:item_id])
    if @collection.items.include?(item)
      @collection.items.delete(item)
      update_collection_cover
      render json: { success: true, saved: false, message: "Предмет удалён из коллекции." }
    else
      @collection.items << item
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
    params.require(:collection).permit(:name, :private, :image_url)
  end

  def authorize_user!
    unless @collection.user_id == current_user.id
      render json: { success: false, error: "У вас нет прав на изменение этой коллекции." }, status: :forbidden
    end
  end

  def update_collection_cover
    return if @collection.image_url.present? && !@collection.default?
    @collection.image_url = @collection.cover_image_url
    @collection.save! if @collection.changed?
  end
end