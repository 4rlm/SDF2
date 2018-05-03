class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :destroy]
  before_action :run_create_user_activities
  respond_to :html, :json


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


  def run_create_user_activities
    User.delay(priority: 0).create_user_activities(current_user) if time_since_user_updated > 120
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_user
    #   @user = User.find(params[:id])
    # end

end
