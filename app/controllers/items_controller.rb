class ItemsController < ApplicationController
    load_and_authorize_resource

    def index
        if current_user && current_user.admin?
            # Администратор видит все товары
            @items = Item.all
        elsif current_user
            # Авторизованные пользователи видят только свои товары
            @items = current_user.items
        else
            # Гости видят только публичные товары
            @items = Item.joins(:post).where(posts: { public: true })
        end
    end

    def show
        @item = Item.find(params[:id])
    end

    def new
        @item = Item.new
    end

    def edit
    end

    def create
        @item = current_user.items.new(item_params)

        respond_to do |format|
        if @item.save
            format.html { redirect_to item_url(@item), notice: "Item was successfully created." }
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
            format.html { redirect_to item_url(@item), notice: "Item was successfully updated." }
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
        format.html { redirect_to items_path, status: :see_other, notice: "Item was successfully destroyed." }
        format.json { head :no_content }
        end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def item_params
      params.require(:item).permit(:name, :description, :image_url, :purchase_url, :price, :post_id)
    end
  
end