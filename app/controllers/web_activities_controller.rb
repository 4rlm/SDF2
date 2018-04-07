class WebActivitiesController < ApplicationController
  before_action :set_web_activity, only: [:show, :edit, :update, :destroy]

  # GET /web_activities
  # GET /web_activities.json
  def index
    @web_activities = WebActivity.all
  end


  def follow_all
    WebActivity.where(user_id: current_user.id, web_id: [params[:web_ids]]).update_all(fav_sts: true)
    after_fav_hide_switch
  end

  def unfollow_all
    web_ids = helpers.get_followed_web_ids(params[:web_ids])
    WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(fav_sts: false)
    after_fav_hide_switch
  end

  def hide_all
    WebActivity.where(user_id: current_user.id, web_id: [params[:web_ids]]).update_all(hide_sts: true)
    after_fav_hide_switch
  end

  def unhide_all
    web_ids = helpers.get_hidden_web_ids(params[:web_ids])
    WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(hide_sts: false)
    after_fav_hide_switch
  end

  def after_fav_hide_switch
    if params['source_path'] == 'webs_path'
      redirect_to webs_path
    elsif params['source_path'] == 'user_path'
      redirect_to current_user
    elsif params['source_path'] == 'conts_path'
      redirect_to conts_path
    end
  end


  # GET /web_activities/1
  # GET /web_activities/1.json
  def show
  end

  # GET /web_activities/new
  def new
    @web_activity = WebActivity.new
  end

  # GET /web_activities/1/edit
  def edit
  end

  # POST /web_activities
  # POST /web_activities.json
  def create
    @web_activity = WebActivity.new(web_activity_params)

    respond_to do |format|
      if @web_activity.save
        format.html { redirect_to @web_activity, notice: 'Web web_activity was successfully created.' }
        format.json { render :show, status: :created, location: @web_activity }
      else
        format.html { render :new }
        format.json { render json: @web_activity.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    binding.pry
    if @web_activity.update(web_activity_params)
      respond_to do |format|
        if params[:web_activity][:form_id] == 'toggle_fav_form'
          binding.pry
          format.js { render :update_toggle_fav, status: :ok, location: @web_activity }
        elsif params[:web_activity][:form_id] == 'toggle_hide_form'
          format.js { render :update_toggle_hide, status: :ok, location: @web_activity }
        else
          format.html { redirect_to @web_activity, notice: 'web_activity was successfully updated.' }
          format.json { render :show, status: :ok, location: @web_activity }
        end
      end
    else
      format.html { render :edit }
      format.json { render json: @web_activity.errors, status: :unprocessable_entity }
    end
  end

  # DELETE /web_activities/1
  # DELETE /web_activities/1.json
  def destroy
    @web_activity.destroy
    respond_to do |format|
      format.html { redirect_to web_activities_url, notice: 'Web web_activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_web_activity
      @web_activity = WebActivity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def web_activity_params
      params.require(:web_activity).permit(:id, :user_id, :web_id, :export_id, :fav_sts, :hide_sts, :created_at, :updated_at)
    end
end