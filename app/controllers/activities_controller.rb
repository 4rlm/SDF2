class ActivitiesController < ApplicationController

  # GET /activities
  # GET /activities.json
  def index
    @activities = Activity.all
  end

  def show
    respond_to do |format|
      format.html
      format.js
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
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to acts_url, notice: 'Activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /toggle_sts
  def toggle_sts
    activity = Activity.where(id: params[:activity_id]).update_all(fav_sts: params[:fav_sts])
    acty = Activity.find_by(id: params[:activity_id])
    redirect_back fallback_location: root_path
  end

  private
    def set_activity
      @activity = Activity.find(params[:id])
    end

    def activities_params
      params.require(:activity).permit()
    end

end
