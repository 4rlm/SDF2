class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :destroy]
  respond_to :html, :json

  # GET /users
  # GET /users.json
  def index
    # @users = User.all
    @users = User.all.paginate(page: params[:page], per_page: 20)

    respond_to do |format|
      format.json # show.js.erb
      format.html # show.html.erb
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    helpers.create_all_activities(@user.id)
  end

  # DELETE /users/1
  # DELETE /users/1.json
  # def destroy
  #   @user.destroy
  #   respond_to do |format|
  #     format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end


  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_user
    #   @user = User.find(params[:id])
    # end

end
