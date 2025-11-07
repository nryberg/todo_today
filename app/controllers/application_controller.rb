class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # Feature flag helper for Google OAuth
  def google_oauth_enabled?
    ENV['ENABLE_GOOGLE_OAUTH']&.downcase == 'true'
  end
  helper_method :google_oauth_enabled?

end
