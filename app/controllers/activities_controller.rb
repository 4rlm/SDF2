class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index
    @activities = Activity.all.paginate(page: params[:page], per_page: 50)

    respond_to do |format|
      format.js # show.js.erb
      format.json # show.js.erb
      format.html # show.html.erb
    end
  end


  def show
    respond_to do |format|
      format.js # show.js.erb
      format.json # show.js.erb
      format.html # show.html.erb
    end
  end


  def new
    @activity = Activity.new
  end


  def edit
  end


  def create
    @activity = Activity.new(activity_params)
    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: 'Activity was successfully created.' }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    if @activity.update(activity_params)
      respond_to do |format|
        if params[:activity][:form_id] == 'toggle_fav_form'
          format.js { render :update_toggle_fav, status: :ok, location: @activity }
        elsif params[:activity][:form_id] == 'toggle_hide_form'
          format.js { render :update_toggle_hide, status: :ok, location: @activity }
        else
          format.html { redirect_to @activity, notice: 'activity was successfully updated.' }
          format.json { render :show, status: :ok, location: @activity }
        end
      end
    else
      format.html { render :edit }
      format.json { render json: @activity.errors, status: :unprocessable_entity }
    end
  end


  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to acts_url, notice: 'Activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
    def set_activity
      @activity = Activity.find(params[:id]) # if params[:id].is_a?(Integer)
    end

    def activity_params
      params.require(:activity).permit(:id, :user_id, :export_id, :mod_name, :mod_id, :fav_sts, :hide_sts, :url, :created_at, :updated_at)
    end

end
