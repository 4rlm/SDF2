class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index
    @activities = Activity.all.paginate(page: params[:page], per_page: 50)

    respond_to do |format|
      format.json # show.js.erb
      format.html # show.html.erb
    end

    # respond_to do |format|
      # format.html { redirect_to activities_path(@activities), notice: 'Returning Activities.' }
      # format.html { render json: @activities }
      # format.json { render :'activities/index', status: :ok, location: @activities }
      # format.json { render :index, status: :ok, location: @activities }
      # format.html { redirect_to @activities }
      # format.json { render :index, status: :ok, location: @activities, layout: true }
      # format.js # show.js.erb
      # format.html # show.html.erb
      #   format.html { redirect_to @activities }
    # end


  end

  def show

    respond_to do |format|
      binding.pry
      format.js # show.js.erb
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
    respond_to do |format|
      if @activity.update(activity_params)
        binding.pry
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
    @activity = Activity.find(params[:id])
    sts_hsh = { fav_sts: params[:fav_sts], hide_sts: params[:hide_sts] }&.delete_if {|k,v| v.blank?}
    @activity.update(sts_hsh)
    binding.pry

    # respond_to do |format|
    #   if @activity.update(sts_hsh)
    #     format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
    #     # format.json { render :toggle_sts, status: :ok, location: @activity, layout: true }
    #     format.json { render :'webs/index', status: :ok, location: @activity }
    #     # format.json { render :toggle_sts, status: :ok, location: @activity }
    #   end
    # end

    respond_to do |format|
      format.json # show.js.erb
      format.html # show.html.erb
    end

    # @activity.update(sts_hsh)
    ## BELOW WORKS, BUT RETURNING WHOLE PARTIAL.  NEED TO RETURN BETTER JSON.
    # respond_to do |format|
      # format.html { redirect_back fallback_location: root_path }
      # format.html { redirect_to toggle_sts_activities_path(@activity), notice: 'Activity was successfully updated.' }
      # format.json { render :toggle_sts, status: :ok, location: @activity }

      # format.js { render :'activities/toggle_sts', status: :ok, object: @activity }
      # format.html { redirect_to Web.find(@activity.mod_id), notice: 'Status was successfully updated.' }
      # format.json { render :show, status: :ok, location: @activity }
      # format.js { render :show, status: :ok, location: @activity }
      # format.js
      # format.js { render :@activity }
      # format.js { render :'webs/index', status: :ok, location: @activity }
      # format.js { render :toggle_sts, status: :ok, location: @activity }
    # end

    # redirect_back(fallback_location: root_path)
    redirect_back(fallback_location: @activity)
    # redirect_back(fallback: product, notice: "Activated")
    # redirect_back fallback_location: root_path
  end

  private
    def set_activity
      @activity = Activity.find(params[:id]) # if params[:id].is_a?(Integer)
      binding.pry
    end

    # def activities_params
    #   params.require(:activity).permit()
    # end

end
