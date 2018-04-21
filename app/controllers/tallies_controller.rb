class TalliesController < ApplicationController
  # before_action :set_tally, only: [:show, :edit, :update, :destroy]
  before_action :basic_and_up

  include TalliesHelper


  # GET /tallies
  # GET /tallies.json
  def index
    @tallies = Tally.all
  end


  def refresh_process
    Start.get_process_sts
    @process_sts = ProcessStatus.first

    respond_to do |format|
      format.js { render :refresh_process, status: :ok, process_sts: @process_sts }
    end

  end



  def generate_csv
    generate_csv_tally_helper(params[:tally_hsh])
    @tally_hsh = params[:tally_hsh]
    @tally_hsh[:tally_id] = "#{@tally_hsh[:mod_name].downcase}_#{@tally_hsh[:tally_scope]}"

    respond_to do |format|
      format.js { render :update_download_tallies, status: :ok, tally_hsh: @tally_hsh }
    end

    # redirect_to tallies_path
  end


  def follow_all
    follow_all_tally_helper(params[:tally_hsh])

    @tally_hsh = params[:tally_hsh]
    @tally_hsh[:tally_id] = "#{@tally_hsh[:mod_name].downcase}_#{@tally_hsh[:tally_scope]}"

    respond_to do |format|
      format.js { render :update_follow_all, status: :ok, tally_hsh: @tally_hsh }
    end

    # redirect_to tallies_path
  end

  def unfollow_all
    unfollow_all_tally_helper(params[:tally_hsh])

    @tally_hsh = params[:tally_hsh]
    @tally_hsh[:tally_id] = "#{@tally_hsh[:mod_name].downcase}_#{@tally_hsh[:tally_scope]}"

    respond_to do |format|
      format.js { render :update_unfollow_all, status: :ok, tally_hsh: @tally_hsh }
    end

    # redirect_to tallies_path
  end

  def hide_all
    hide_all_tally_helper(params[:tally_hsh])

    @tally_hsh = params[:tally_hsh]
    @tally_hsh[:tally_id] = "#{@tally_hsh[:mod_name].downcase}_#{@tally_hsh[:tally_scope]}"

    respond_to do |format|
      format.js { render :update_hide_all, status: :ok, tally_hsh: @tally_hsh }
    end

    # redirect_to tallies_path
  end

  def unhide_all
    unhide_all_tally_helper(params[:tally_hsh])

    @tally_hsh = params[:tally_hsh]
    @tally_hsh[:tally_id] = "#{@tally_hsh[:mod_name].downcase}_#{@tally_hsh[:tally_scope]}"

    respond_to do |format|
      format.js { render :update_unhide_all, status: :ok, tally_hsh: @tally_hsh }
    end

    # redirect_to tallies_path
  end



  # GET /tallies/1
  # GET /tallies/1.json
  def show
  end

  # GET /tallies/new
  def new
    # @tally = Tally.new
  end

  # GET /tallies/1/edit
  def edit
  end

  # POST /tallies
  # POST /tallies.json
  def create
    @tally = Tally.new(tally_params)

    respond_to do |format|
      if @tally.save
        format.html { redirect_to @tally, notice: 'Tally was successfully created.' }
        format.json { render :show, status: :created, location: @tally }
      else
        format.html { render :new }
        format.json { render json: @tally.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tallies/1
  # PATCH/PUT /tallies/1.json
  def update
    respond_to do |format|
      if @tally.update(tally_params)
        format.html { redirect_to @tally, notice: 'Tally was successfully updated.' }
        format.json { render :show, status: :ok, location: @tally }
      else
        format.html { render :edit }
        format.json { render json: @tally.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tallies/1
  # DELETE /tallies/1.json
  def destroy
    @tally.destroy
    respond_to do |format|
      format.html { redirect_to tallies_url, notice: 'Tally was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tally
      @tally = Tally.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tally_params
      params.fetch(:tally, {})
    end
end
