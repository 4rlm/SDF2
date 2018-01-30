class WebsController < ApplicationController
  before_action :set_web, only: [:show, :edit, :update, :destroy]

  # GET /webs
  # GET /webs.json
  def index
    # @webs = Web.all[0..100]
    @webs = Web.where(urlx: FALSE).order("url_ver_date DESC")[0..100]
  end

  # GET /webs/1
  # GET /webs/1.json
  def show
  end

  # GET /webs/new
  def new
    @web = Web.new
  end

  # GET /webs/1/edit
  def edit
  end

  # POST /webs
  # POST /webs.json
  def create
    @web = Web.new(web_params)

    respond_to do |format|
      if @web.save
        format.html { redirect_to @web, notice: 'Web was successfully created.' }
        format.json { render :show, status: :created, location: @web }
      else
        format.html { render :new }
        format.json { render json: @web.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /webs/1
  # PATCH/PUT /webs/1.json
  def update
    respond_to do |format|
      if @web.update(web_params)
        format.html { redirect_to @web, notice: 'Web was successfully updated.' }
        format.json { render :show, status: :ok, location: @web }
      else
        format.html { render :edit }
        format.json { render json: @web.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /webs/1
  # DELETE /webs/1.json
  def destroy
    @web.destroy
    respond_to do |format|
      format.html { redirect_to webs_url, notice: 'Web was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_web
      @web = Web.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def web_params
      params.require(:web).permit(:url, :urlx, :fwd_web_id, :fwd_url, :url_ver_sts, :sts_code, :url_ver_date, :tmp_sts, :temp_name, :tmp_date, :slink_sts, :llink_sts, :stext_sts, :ltext_sts, :pge_date, :as_sts, :as_date, :cs_sts, :cs_date, :created_at, :updated_at)
    end
end
