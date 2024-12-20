class ItemsController < ApplicationController
    load_and_authorize_resource
  
    def index
      if current_profile&.user&.admin?
        # Администратор видит все товары
        @items = Item.all
      elsif current_profile
        # Авторизованные пользователи видят только свои товары
        @items = current_profile.items
      else
        # Гости видят только публичные товары
        @items = Item.joins(:post).where(posts: { public: true })
      end
    end
  
    def show
      # @item загружается автоматически благодаря load_and_authorize_resource
    end
  
    def new
      # @item создаётся автоматически через load_and_authorize_resource
    end
  
    def edit
      # @item загружается автоматически через load_and_authorize_resource
    end
  
    def create
      @item = current_profile.items.new(item_params)
  
      respond_to do |format|
        if @item.save
          format.html { redirect_to item_url(@item), notice: "Товар успешно создан." }
          format.json { render :show, status: :created, location: @item }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def update
      respond_to do |format|
        if @item.update(item_params)
          format.html { redirect_to item_url(@item), notice: "Товар успешно обновлён." }
          format.json { render :show, status: :ok, location: @item }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def destroy
      @item.destroy!
  
      respond_to do |format|
        format.html { redirect_to items_path, status: :see_other, notice: "Товар успешно удалён." }
        format.json { head :no_content }
      end
    end
  
    private
  
    def item_params
      params.require(:item).permit(:name, :description, :image_url, :purchase_url, :price, :post_id)
    end
  end