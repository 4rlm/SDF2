class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  # before_action :authenticate_user!, except: [:index, :show]

  ### BELOW OLD STUFF FROM BCRYPT - CAN DELETE AFTER DEVISE SET UP ###
  # before_action :require_login
  # before_action :logged_in?

  # private

  # def require_login
  #   unless logged_in?
  #     flash[:error] = "You must be logged in to access this section"
  #     redirect_to login_path
  #     # redirect_to login_url # halts request cycle
  #   end
  # end
  #
  # def logged_in?
  #   @current_user ||= User.find(session[:user_id]) if session[:user_id]
  # end
  #
  # helper_method :logged_in?

end
