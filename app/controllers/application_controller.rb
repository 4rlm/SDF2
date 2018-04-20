class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  ## Custom: Strong Parameters White Listing
  before_action :configure_permitted_parameters, if: :devise_controller?

  def block_pending_users
    unless current_user && current_user.role != "admin"
      flash[:alert] = "Please wait for admin approval."
      redirect_to root_path
    end
  end

  # respond_to do |format|
  #   format.json # show.js.erb
  #   format.html # show.html.erb
  # end

  protected


  # ========== Detect User's Level(Role) ==========

  def intermediate_and_up
    unless current_user && (current_user.intermediate? || current_user.advanced? || current_user.admin?)
      flash[:alert] = "NOT AUTHORIZED [2]"
      redirect_to root_path
    end
  end

  def advanced_and_up
    unless current_user && (current_user.advanced? || current_user.admin?)
      flash[:alert] = "NOT AUTHORIZED [3]"
      redirect_to root_path
    end
  end

  def admin_only
    unless current_user && current_user.admin?
      flash[:alert] = "NOT AUTHORIZED [4]"
      redirect_to root_path
    end
  end


  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :role, :approved])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :role, :approved])
  end


end
