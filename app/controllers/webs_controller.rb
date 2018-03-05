class WebsController < ApplicationController
  before_action :set_web, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json

  # GET /webs
  # GET /webs.json
  def index
    # @search = Web.all.ransack(params[:q])
    # @webs = @search.result(distinct: true).paginate(page: params[:page], per_page: 50)
    
    @webs = Web.all.paginate(page: params[:page], per_page: 50)
  
    respond_with(@webs)
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
      params.require(:act).permit(:id, :url, :url_sts_code, :cop, :temp_name, :url_sts, :temp_sts, :page_sts, :cs_sts, :brand_sts, :url_date, :tmp_date, :page_date, :cs_date, :brand_date, :fwd_url, :web_changed, :wx_date)
    end
end
