class ContActivitiesController < ApplicationController
  before_action :set_cont_activity, only: [:show, :edit, :update, :destroy]

  # GET /cont_activities
  # GET /cont_activities.json
  def index
    @cont_activities = ContActivity.all
  end



  def follow_all
    helpers.switch_cont_fav_hide([params[:cont_ids]], 'fav_sts', true)
    after_fav_hide_switch
  end

  def unfollow_all
    cont_ids = helpers.get_followed_cont_ids(params[:cont_ids])
    helpers.switch_cont_fav_hide(cont_ids, 'fav_sts', false)
    after_fav_hide_switch
  end

  def hide_all
    helpers.switch_cont_fav_hide([params[:cont_ids]], 'hide_sts', true)
    after_fav_hide_switch
  end

  def unhide_all
    cont_ids = helpers.get_hidden_cont_ids(params[:cont_ids])
    helpers.switch_cont_fav_hide(cont_ids, 'hide_sts', false)
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




  # GET /cont_activities/1
  # GET /cont_activities/1.json
  def show
  end

  # GET /cont_activities/new
  def new
    @cont_activity = ContActivity.new
  end

  # GET /cont_activities/1/edit
  def edit
  end

  # POST /cont_activities
  # POST /cont_activities.json
  def create
    @cont_activity = ContActivity.new(cont_activity_params)

    respond_to do |format|
      if @cont_activity.save
        format.html { redirect_to @cont_activity, notice: 'Cont activity was successfully created.' }
        format.json { render :show, status: :created, location: @cont_activity }
      else
        format.html { render :new }
        format.json { render json: @cont_activity.errors, status: :unprocessable_entity }
      end
    end
  end


  # # PATCH/PUT /cont_activities/1
  # # PATCH/PUT /cont_activities/1.json
  # def update
  #   respond_to do |format|
  #     if @cont_activity.update(cont_activity_params)
  #       format.html { redirect_to @cont_activity, notice: 'Cont activity was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @cont_activity }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @cont_activity.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end


  def update
    # binding.pry
    if @cont_activity.update(cont_activity_params)
      respond_to do |format|
        if params[:cont_activity][:form_id] == 'toggle_fav_form'
          format.js { render :update_toggle_fav, status: :ok, location: @cont_activity }
        elsif params[:cont_activity][:form_id] == 'toggle_hide_form'
          format.js { render :update_toggle_hide, status: :ok, location: @cont_activity }
        else
          format.html { redirect_to @cont_activity, notice: 'cont_activity was successfully updated.' }
          format.json { render :show, status: :ok, location: @cont_activity }
        end
      end
    else
      format.html { render :edit }
      format.json { render json: @cont_activity.errors, status: :unprocessable_entity }
    end
  end


  # DELETE /cont_activities/1
  # DELETE /cont_activities/1.json
  def destroy
    @cont_activity.destroy
    respond_to do |format|
      format.html { redirect_to cont_activities_url, notice: 'Cont activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cont_activity
      @cont_activity = ContActivity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cont_activity_params
      params.require(:cont_activity).permit(:id, :user_id, :cont_id, :export_id, :fav_sts, :hide_sts, :created_at, :updated_at)
    end
end
