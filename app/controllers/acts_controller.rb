class ActsController < ApplicationController
  before_action :set_act, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction

  # GET /acts
  # GET /acts.json
  def index
    # @acts = ActsDatatable.new(view_context)
    # @acts = Act.where(actx: FALSE, act_gp_sts: 'Valid:gp').
    #   order(sort_column + ' ' + sort_direction).
    #   paginate(:page => params[:page], :per_page => 50)

    @query = Act.where(actx: FALSE, act_gp_sts: 'Valid:gp').ransack(params[:q])
    @acts = @query.result.paginate(:page => params[:page], :per_page => 50)

    respond_to do |format|
      format.html
      format.js
    end
    ###################

    # @search = Space.search(params[:q])
    # @spaces = @search.result
    # @q = Space.ransack(params[:q])
    # @spaces = @q.result.includes(:addresses)
    # @spaces = @q.result(distinct: true).includes(:address)
    # @q.build_condition
    # or use `to_a.uniq` to remove duplicates (can also be done in the view):
    # @people = @q.result.includes(:articles).page(params[:page]).to_a.uniq

  end

  # GET /acts/1
  # GET /acts/1.json
  def show
    # respond_to do |format|
    #   format.html
    #   format.js
    # end
  end

  # GET /acts/new
  def new
    @act = Act.new
  end

  # GET /acts/1/edit
  def edit
  end

  # POST /acts
  # POST /acts.json
  def create
    @act = Act.new(act_params)

    respond_to do |format|
      if @act.save
        format.html { redirect_to @act, notice: 'Act was successfully created.' }
        format.json { render :show, status: :created, location: @act }
      else
        format.html { render :new }
        format.json { render json: @act.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /acts/1
  # PATCH/PUT /acts/1.json
  def update
    respond_to do |format|
      if @act.update(act_params)
        format.html { redirect_to @act, notice: 'Act was successfully updated.' }
        format.json { render :show, status: :ok, location: @act }
      else
        format.html { render :edit }
        format.json { render json: @act.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /acts/1
  # DELETE /acts/1.json
  def destroy
    @act.destroy
    respond_to do |format|
      format.html { redirect_to acts_url, notice: 'Act was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def sort_column
      Act.column_names.include?(params[:sort]) ? params[:sort] : "act_name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_act
      @act = Act.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def act_params

      # ORIGINAL
      params.require(:act).permit(:act_name, :act_gp_date, :updated_at)

      # WORKING NESTED ATTRIBUTE - Cont
      # params.require(:act).permit(:src, :sts, :crma, :name, conts_attributes: [ :id, :first_name ] )

      # # WORKING NESTED ATTRIBUTE - Webs
      # params.require(:act).permit(:src, :sts, :crma, :name, web_attributes: [:src, :sts, :url, :staff_page, :locations_page, :created_at, :updated_at ])

      # # WORKING NESTED ATTRIBUTE - Adrs
      # params.require(:act).permit(:src, :sts, :crma, :name, adr_attributes: [:src, :sts, :street, :unit, :city, :state, :zip, :pin, :latitude, :longitude, :created_at, :updated_at ])

      #######################################

      # # WORKING NESTED ATTRIBUTE - Webs && Adrs ???
      # params.require(:act).permit(:id, :src, :sts, :crma, :name, :created_at, :updated_at,
      #     web_attributes: [:id, :src, :sts, :url, :staff_page, :locations_page, :created_at, :updated_at ],
      #     adr_attributes: [:id, :src, :sts, :street, :unit, :city, :state, :zip, :pin, :latitude, :longitude, :created_at, :updated_at ],
      #     phone_attributes: [:id, :src, :sts, :phone, :created_at, :updated_at ])

      #######################################

      # WORKING NESTED ATTRIBUTE - Phones
      # params.require(:act).permit(:src, :sts, :crma, :name, phone_attributes: [:src, :sts, :phone, :created_at, :updated_at ])


    end
end
