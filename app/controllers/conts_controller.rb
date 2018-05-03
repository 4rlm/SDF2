class ContsController < ApplicationController
  before_action :set_cont, only: [:show, :edit, :update, :destroy]
  before_action :basic_and_up
  helper_method :sort_column, :sort_direction
  require 'will_paginate/array'

  def index

    if params[:bypass_cont_ids]&.any?
      @conts = Cont.where(id: [params[:bypass_cont_ids]]).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    elsif params[:grab_followed].present?
      cont_ids = current_user.cont_activities.followed.pluck(:cont_id)
      @conts = Cont.where(id: [cont_ids]).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    elsif params[:grab_hidden].present?
      cont_ids = current_user.cont_activities.hidden.pluck(:cont_id)
      @conts = Cont.where(id: [cont_ids]).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    else
      params.delete('q') if params['q'].present? && params['q'] == 'q'

      ## Splits 'cont_any' strings into array, if string and has ','
      if params[:q].present?
        conts_helper = Object.new.extend(ContsHelper)
        params[:q] = conts_helper.split_ransack_params(params[:q])
      end

      @cq = Cont.ransack(params[:q])
      @conts = @cq.result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities).order("updated_at DESC").paginate(page: params[:page], per_page: 20)
    end

    @cq = Cont.ransack(params[:q]) if !@cq.present?
  end


  def show_web
    @cont = Cont.find(params[:cont_id])
    respond_to do |format|
      format.js { render :show_web, status: :ok, location: @cont }
    end
  end


  def followed
    params[:bypass_cont_ids] = helpers.get_followed_cont_ids(nil)
    redirect_to conts_path(params)
  end

  def hidden
    params[:bypass_cont_ids] = helpers.get_hidden_cont_ids(nil)
    redirect_to conts_path(params)
  end


  def generate_csv
    if params[:q].present?
      Cont.generate_csv_conts(params, current_user)

      respond_to do |format|
        format.js { render :download_conts, status: :ok, location: @conts }
      end
    end
  end


  def search
    if params[:q]['q_name_cont_any'].present?
      q_name = params[:q].delete('q_name_cont_any')
      ContCsvTool.new.save_cont_queries(q_name, params, current_user)
    end

    index
    render :index
  end


  def show
  end

  def new
    @cont = Cont.new
  end

  def edit
  end

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
