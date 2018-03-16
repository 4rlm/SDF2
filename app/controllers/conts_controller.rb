class ContsController < ApplicationController
  before_action :set_cont, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  helper_method :sort_column, :sort_direction


  # GET /conts
  # GET /conts.json
  def index
    # @conts = Cont.all

    ## Splits 'cont_any' strings into array, if string and has ','
    if !params[:q].nil?
      conts_helper = Object.new.extend(ContsHelper)
      params[:q] = conts_helper.split_ransack_params(params[:q])
    end

    @cq = Cont.ransack(params[:q])
    @conts = @cq.result(distinct: true).includes(:acts, :web, :brands).paginate(page: params[:page], per_page: 50)

    # respond_with(@conts)
  end

  def search
    index
    render :index
  end

  # GET /conts/1
  # GET /conts/1.json
  def show
  end

  # GET /conts/new
  def new
    @cont = Cont.new
  end

  # GET /conts/1/edit
  def edit
  end

  # POST /conts
  # POST /conts.json
  def create
    @cont = Cont.new(cont_params)

    respond_to do |format|
      if @cont.save
        format.html { redirect_to @cont, notice: 'Cont was successfully created.' }
        format.json { render :show, status: :created, location: @cont }
      else
        format.html { render :new }
        format.json { render json: @cont.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conts/1
  # PATCH/PUT /conts/1.json
  def update
    respond_to do |format|
      if @cont.update(cont_params)
        format.html { redirect_to @cont, notice: 'Cont was successfully updated.' }
        format.json { render :show, status: :ok, location: @cont }
      else
        format.html { render :edit }
        format.json { render json: @cont.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conts/1
  # DELETE /conts/1.json
  def destroy
    @cont.destroy
    respond_to do |format|
      format.html { redirect_to conts_url, notice: 'Cont was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def sort_column
      Cont.column_names.include?(params[:sort]) ? params[:sort] : "full_name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_cont
      @cont = Cont.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cont_params
      # params.require(:cont).permit(:src, :sts, :act_id, :crma, :crmc, :first_name, :last_name, :email)

      params.require(:cont).permit(:id, :first_name, :last_name, :full_name, :job_title, :job_desc, :email, :phone, :cs_sts, :cs_date, :email_changed, :cont_changed, :job_changed, :cx_date, :web_id)
    end
end
