class SessionsController < ApplicationController
  # skip_before_action :require_login, only: [:new, :create]

  def new
  end

  def create
    @current_user = User.find_by(email: params[:email])
    respond_to do |format|
      if @current_user && @current_user.authenticate(params[:password])
        session[:user_id] = @current_user.id
        format.html { redirect_to @current_user, notice: "Welcome back, #{@current_user.username.capitalize}!" }
        format.json { render :'user/show', status: :ok, location: @current_user }
      else
        format.html { redirect_to login_path, notice: "Username or Password not recognized." }
        format.json { render json: @current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    session[:user_id] = nil
    # redirect_to root_url, notice: 'Logged out!'
     respond_to do |format|
       format.html { redirect_to root_url, notice: 'Logged out!' }
       format.js { render :root_url, notice: 'Logged out!' }
     end
  end

end
