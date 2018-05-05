class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :destroy]
  before_action :run_create_user_activities
  # before_action :test_flash


  def index
    # @users = User.all
    @users = User.all.paginate(page: params[:page], per_page: 20)
    respond_to do |format|
      format.json # show.js.erb
      format.html # show.html.erb
    end
  end


  def show
    @user = User.find(params[:id])
  end


  # def test_flash
  #   flash[:notice] = "notice-success / User Controller"
  #   # redirect_to @user
  #   # format.html { redirect_to Space.find(@address.space_id), notice: 'Address was successfully created.' }
  # end



  def run_create_user_activities
    if time_since_user_updated > 120
      flash[:alert] = "Alert: Syncing Newly Scraped Data.  May slow down app during next 1-2 minutes."
      User.delay(priority: 0).create_user_activities(current_user)
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_user
    #   @user = User.find(params[:id])
    # end

end
