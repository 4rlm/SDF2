class WebsController < ApplicationController
  before_action :set_web, only: [:show, :edit, :update, :destroy]
  before_action :basic_and_up

  # respond_to :html, :json
  helper_method :sort_column, :sort_direction


  # GET /webs
  # GET /webs.json
  def index
    if params[:tally_scope].present?
      @webs = Web.send(params[:tally_scope]).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    elsif params[:bypass_web_ids]&.any?
      @webs = Web.where(id: [params[:bypass_web_ids]]).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    elsif params[:fwd_web_id].present?
      @webs = Web.where(id: params[:fwd_web_id]).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    elsif params[:grab_followed].present?
      web_ids = current_user.web_activities.followed.pluck(:web_id)
      @webs = Web.where(id: [web_ids]).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    elsif params[:grab_hidden].present?
      web_ids = current_user.web_activities.hidden.pluck(:web_id)
      @webs = Web.where(id: [web_ids]).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    else
      params.delete('q') if params['q'].present? && params['q'] == 'q'

      ## Splits 'cont_any' strings into array, if string and has ','
      if params[:q].present?
        webs_helper = Object.new.extend(WebsHelper)
        params[:q] = webs_helper.split_ransack_params(params[:q])
      end

      @wq = Web.ransack(params[:q])
      @webs = @wq.result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities).order("updated_at DESC").paginate(page: params[:page], per_page: 20)

    end

    @wq = Web.ransack(params[:q]) if !@wq.present?

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.json # show.js.erb
    # end
  end


  def show_conts
    @web = Web.find(params[:web_id])

    respond_to do |format|
      format.js { render :show_conts, status: :ok, location: @web }
    end
  end


  def generate_csv

    if params[:q].present?
      # WebCsvTool.new(params, current_user).delay.start_web_acts_csv_and_log
      WebCsvTool.new(params, current_user).start_web_acts_csv_and_log

      respond_to do |format|
        format.js { render :download_webs, status: :ok, location: @webs }
      end

      # params['action'] = 'index'
      # redirect_to webs_path(params)
    end
  end


  def search
    if params[:q]['q_name_cont_any'].present?
      q_name = params[:q].delete('q_name_cont_any')
      WebCsvTool.new(params, current_user).save_web_queries(q_name)
    end

    # index
    # render :index
    redirect_to webs_path(params.permit!)
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
    def sort_column
      Web.column_names.include?(params[:sort]) ? params[:sort] : "url"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_web
      @web = Web.find(params[:id]) if params[:id].is_a?(Integer)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def web_params
      params.require(:act).permit(:id, :url, :url_sts_code, :cop, :url_sts, :temp_sts, :page_sts, :cs_sts, :brand_sts, :timeout, :url_date, :tmp_date, :page_date, :cs_date, :brand_date, :fwd_url, :web_changed, :wx_date, :q, temp_name: [])
    end
end
