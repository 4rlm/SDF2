class ActActivitiesController < ApplicationController
  before_action :set_act_activity, only: [:show, :edit, :update, :destroy]

  # GET /act_activities
  # GET /act_activities.json
  def index
    @act_activities = ActActivity.all
  end



  def follow_all
    binding.pry
    helpers.switch_act_fav_hide([params[:act_ids]], 'fav_sts', true)
    after_fav_hide_switch
  end

  def unfollow_all
    current_user.act_activities.followed.update_all(fav_sts: false)
    after_fav_hide_switch
  end

  def hide_all
    binding.pry
    helpers.switch_act_fav_hide([params[:act_ids]], 'hide_sts', true)
    after_fav_hide_switch
  end

  def unhide_all
    current_user.act_activities.hidden.update_all(hide_sts: false)
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




  # GET /act_activities/1
  # GET /act_activities/1.json
  def show
  end

  # GET /act_activities/new
  def new
    @act_activity = ActActivity.new
  end

  # GET /act_activities/1/edit
  def edit
  end

  # POST /act_activities
  # POST /act_activities.json
  def create
    @act_activity = ActActivity.new(act_activity_params)

    respond_to do |format|
      if @act_activity.save
        format.html { redirect_to @act_activity, notice: 'Act activity was successfully created.' }
        format.json { render :show, status: :created, location: @act_activity }
      else
        format.html { render :new }
        format.json { render json: @act_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /act_activities/1
  # PATCH/PUT /act_activities/1.json
  # def update
  #   respond_to do |format|
  #     if @act_activity.update(act_activity_params)
  #       format.html { redirect_to @act_activity, notice: 'Act activity was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @act_activity }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @act_activity.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def update
    # binding.pry
    if @act_activity.update(act_activity_params)
      respond_to do |format|
        if params[:act_activity][:form_id] == 'toggle_fav_form'
          format.js { render :update_toggle_fav, status: :ok, location: @act_activity }
        elsif params[:act_activity][:form_id] == 'toggle_hide_form'
          format.js { render :update_toggle_hide, status: :ok, location: @act_activity }
        else
          format.html { redirect_to @act_activity, notice: 'act_activity was successfully updated.' }
          format.json { render :show, status: :ok, location: @act_activity }
        end
      end
    else
      format.html { render :edit }
      format.json { render json: @act_activity.errors, status: :unprocessable_entity }
    end
  end

  # DELETE /act_activities/1
  # DELETE /act_activities/1.json
  def destroy
    @act_activity.destroy
    respond_to do |format|
      format.html { redirect_to act_activities_url, notice: 'Act activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_act_activity
      @act_activity = ActActivity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def act_activity_params
        params.require(:act_activity).permit(:id, :user_id, :act_id, :export_id, :fav_sts, :hide_sts, :created_at, :updated_at)
    end
end
