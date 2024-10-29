class Admin::SubscriptionsController < ApplicationController
    load_and_authorize_resource
  
    def index
      @subscriptions = Subscription.all
    end
  
    def destroy
      @subscription.destroy!
  
      respond_to do |format|
        format.html { redirect_to admin_subscriptions_path, status: :see_other, notice: "Subscription was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    private
      def set_subscription
        @subscription = Subscription.find(params[:id])
      end
end