class ActsController < ApplicationController
  before_action :set_act, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  helper_method :sort_column, :sort_direction

  # GET /acts
  # GET /acts.json
  def index
    # @acts = ActsDatatable.new(view_context)
    # @acts = Act.where(actx: FALSE, act_gp_sts: 'Valid:gp').
    #   order(sort_column + ' ' + sort_direction).
    #   paginate(:page => params[:page], :per_page => 50)


    ## Splits 'cont_any' strings into array, if string and has ','
    if !params[:q].nil?
      acts_helper = Object.new.extend(ActsHelper)
      params[:q] = acts_helper.split_ransack_params(params[:q])
    end

    ## New Query Below - Works well!
    # acts = Act.includes(:adrs, :webs).where(acts: {actx: FALSE, act_gp_sts: 'Valid:gp'}).where(webs: {urlx: FALSE}).where(adrs: {adrx: FALSE}).count

    ## ORIGINAL BELOW
    # @search = Act.where(actx: FALSE, act_gp_sts: 'Valid:gp').ransack(params[:q])

    @search = Act.includes(:adrs, :webs)
      .where(acts: {actx: FALSE, act_gp_sts: 'Valid:gp'})
      .where(webs: {urlx: FALSE, url_ver_sts: 'Valid'})
      .where(adrs: {adrx: FALSE, adr_gp_sts: 'Valid'})
      .ransack(params[:q])

    @acts = @search.result
      .paginate(:page => params[:page], :per_page => 50)
      # .result(distinct: true)
      # .includes(:adrs, :webs, :phones)

    respond_with(@acts)
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
      @act = Act&.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def act_params

      # ORIGINAL
      # params.require(:act).permit(:id, :act_name, :act_gp_date, :updated_at)
      params.require(:act).permit(:id, :act_name, :act_gp_date, :updated_at, adrs_attributes: [ :id, :street, :city, :state, :zip ] )


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
