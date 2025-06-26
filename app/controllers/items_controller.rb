require 'ostruct'

class ItemsController < ApplicationController
  # Авторизация ресурсов через CanCanCan (кроме fetch_data и preview)
  load_and_authorize_resource except: [:fetch_data, :preview]

  # Отключаем CSRF для внешнего POST-запроса (например, парсинга)
  protect_from_forgery with: :null_session, only: [:fetch_data]

  # --- API: Парсинг данных о товаре по ссылке ---
  def fetch_data
    url = params[:url]

    begin
      item_data = ItemParser.parse(url)  # Внешний сервис парсинга
      Rails.logger.debug("Parsed item data: #{item_data.inspect}")

      if item_data[:success]
        render json: item_data
      else
        render json: { success: false }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error("Item parse error: #{e.message}")
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  # --- Превью товара без сохранения в базу ---
  def preview
    @item = OpenStruct.new(params[:item]) # Мокаем объект для отображения
    render partial: "items/item_form", locals: { item: @item }
  end

  # --- Форма создания товара ---
  def new
    @item = Item.new
  end

  # --- Сохранение нового товара ---
  def create
    @item = current_user.items.new(item_params)

    if @item.save
      redirect_to @item, notice: "Товар успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # --- Удаление товара ---
  def destroy
    @item.destroy!
    respond_to do |format|
      format.html { redirect_to items_path, notice: "Товар удалён." }
      format.json { head :no_content }
    end
  end

  private

  # --- Разрешённые параметры ---
  def item_params
    params.require(:item).permit(
      :name,
      :description,
      :image_url,
      :purchase_url,
      :price,
      :post_id,
      :market_icon_url
    )
  end
end
