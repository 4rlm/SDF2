class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_last_request_at, :check_priority_jobs
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected


  # ========== Detect User's Level(Role) ==========

  def basic_and_up
    unless current_user && (current_user.basic? || current_user.intermediate? || current_user.advanced? || current_user.admin?)
      flash[:alert] = "NOT AUTHORIZED [1]"
      redirect_to root_path
    end
  end

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


  def set_last_request_at
    current_user.update(last_sign_in_at: Time.now) if current_user.present? && time_since_user_updated > 30
  end

  def time_since_user_updated
    time_since_updated = current_user.updated_at.strftime("%M").to_i if current_user.present?
  end

  def check_priority_jobs
    Start.priority_jobs if Delayed::Job.any?
  end


end
