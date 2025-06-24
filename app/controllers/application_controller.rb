class ApplicationController < ActionController::Base

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to root_path, alert: exception.message }
    end
  end

  before_action :set_random_tags

  def set_random_tags
    @random_tags = ActsAsTaggableOn::Tag.order("RANDOM()").limit(6)
  end



  protect_from_forgery with: :null_session 
end
