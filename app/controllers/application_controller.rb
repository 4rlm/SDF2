class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  ## Custom: Strong Parameters White Listing
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :role, :approved])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :role, :approved])
  end


end
