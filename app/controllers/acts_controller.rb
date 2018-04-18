class ActsController < ApplicationController
  before_action :set_act, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json
  helper_method :sort_column, :sort_direction

  # GET /acts
  # GET /acts.json
  def index

    if params[:tally_scope].present?
      @acts = Act.send(params[:tally_scope]).paginate(page: params[:page], per_page: 20)
    elsif params[:bypass_web_ids]&.any?
      @acts = Act.where(id: [params[:bypass_act_ids]]).paginate(page: params[:page], per_page: 20)
    elsif params[:grab_followed_acts].present?
      act_ids = current_user.act_activities.followed.pluck(:act_id)
      @acts = Act.where(id: [act_ids]).paginate(page: params[:page], per_page: 20)
    elsif params[:grab_hidden_acts].present?
      act_ids = current_user.act_activities.hidden.pluck(:act_id)
      @acts = Act.where(id: [act_ids]).paginate(page: params[:page], per_page: 20)
    else
      params.delete('q') if params['q'].present? && params['q'] == 'q'

      # Splits 'cont_any' strings into array, if string and has ','
      if params[:q].present?
        acts_helper = Object.new.extend(ActsHelper)
        params[:q] = acts_helper.split_ransack_params(params[:q])
      end

      @aq = Act.ransack(params[:q])
      @acts = @aq.result(distinct: true).includes(:webs, :conts, :brands, :act_activities).paginate(page: params[:page], per_page: 20)
    end

    @aq = Act.ransack(params[:q]) if !@aq.present?

    # respond_to do |format|
    #   format.json # show.js.erb
    #   format.html # show.html.erb
    # end
    #
    # respond_with(@acts)
  end



  # def followed
  #   params[:bypass_act_ids] = helpers.get_followed_act_ids(nil)
  #   redirect_to acts_path(params)
  # end
  #
  # def hidden
  #   params[:bypass_act_ids] = helpers.get_hidden_act_ids(nil)
  #   redirect_to acts_path(params)
  # end

  # def followed_acts
  #   act_ids = helpers.get_followed_act_ids(nil)
  #   params[:bypass_web_ids] = Act.where(id: [act_ids]).map {|act| act.webs.map(&:id) }&.flatten&.compact&.uniq
  #   redirect_to webs_path(params)
  # end
  #
  # def hidden_acts
  #   act_ids = helpers.get_hidden_act_ids(nil)
  #   params[:bypass_web_ids] = Act.where(id: [act_ids]).map {|act| act.webs.map(&:id) }&.flatten&.compact&.uniq
  #   redirect_to webs_path(params)
  # end


  def generate_csv
    if params[:q].present?
      # ActCsvTool.new(params, current_user).delay.start_act_webs_csv_and_log
      ActCsvTool.new(params, current_user).start_act_webs_csv_and_log

      respond_to do |format|
        format.js { render :download_acts, status: :ok, location: @acts }
      end

      # params['action'] = 'index'
      # redirect_to acts_path(params)
    end
  end


  def search
    if params[:q]['q_name_cont_any'].present?
      q_name = params[:q].delete('q_name_cont_any')
      ActCsvTool.new(params, current_user).save_act_queries(q_name)
    end

    redirect_to acts_path(params)
  end



  def show
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @act = Act.new
  end

  def edit
  end

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


    def set_act
      @act = Act.find(params[:id])
    end

    def act_params
      params.require(:act).permit(:id, :act_name, :street, :city, :state, :zip, :phone, :url, :updated_at, :gp_date)
    end
end
