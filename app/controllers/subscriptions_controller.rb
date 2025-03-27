class SubscriptionsController < ApplicationController
    load_and_authorize_resource
  
    def create
      @subscription = Subscription.new(subscription_params)
  
      respond_to do |format|
        if @subscription.save
          format.html { redirect_to root_path, notice: "Вы успешно подписались на рассылку!" }
        else
          format.html { redirect_to root_path, alert: "Ошибка" }
        end
      end
    end
  
    private
      def subscription_params
        params.require(:subscription).permit(:email)
      end
  
  end