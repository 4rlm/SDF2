class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :destroy]
  before_action :create_user_activities
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


  def create_user_activities
    activities_tool = ActivitiesTool.new
    activities_tool.delay(priority: 0).create_web_activities(current_user.id)
    activities_tool.delay(priority: 0).create_act_activities(current_user.id)
    activities_tool.delay(priority: 0).create_cont_activities(current_user.id)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_user
    #   @user = User.find(params[:id])
    # end

end
