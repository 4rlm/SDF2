class ActCsvTool

  def initialize(params, current_user)
    @params = params
    @user = current_user

    if params[:q].present?
      @acts = Act.ransack(params[:q]).result(distinct: true).includes(:webs, :brands)
    elsif params[:tally_scope].present?
      @acts = Act.send(params[:tally_scope])
    end

    @export_date = Time.now
    @file_name = "act_webs_#{@export_date.strftime("%Y%m%d%I%M%S")}.csv"
    @path_and_file = "./public/downloads/#{@file_name}"
  end


  def start_act_webs_csv_and_log
    act_webs_to_csv
    log_act_webs_export
  end

  def save_act_queries(q_name)
    query = @user.queries.find_or_initialize_by(mod_name: 'Act', q_name: q_name)
    query.params = @params
    query.row_count = @acts.count
    query.save
  end


  ############  WEB_ACTS EXPORT  ############
  def act_webs_to_csv
    act_cols = %w(id act_name gp_id gp_sts lat lon street city state zip phone act_changed adr_changed ax_date)
    brand_cols = %w(brand_name)
    web_cols = %w(url fwd_url url_sts cop temp_name cs_sts created_at web_changed wx_date)

    # TESTING ONLY.  COMMENT OUT AFTER TESTING.  LIMITIS ACT SIZE FOR TESTING.
    # @acts = @acts[0..10]

    ## Try to exclude acts marked as hidden true.
    # @exclude_hidden = true
    # if @exclude_hidden == true
    #   unhidden_act_ids = ActActivity.where(user_id: current_user, act_id: [@acts.map(&:id)], hide_sts: false).pluck(:act_id)
    #   @acts = Act.where(id: [unhidden_act_ids])
    # end


    CSV.open(@path_and_file, "wb") do |csv|
      csv.add_row(act_cols + brand_cols + web_cols)
      @acts.each do |act|
        values = act.attributes.slice(*act_cols).values
        values << act.brands&.map { |brand| brand&.brand_name }&.sort&.uniq&.join(', ')

        if act.webs.any?
          act.webs.each do |web|
            csv.add_row(values + web.attributes.slice(*web_cols).values)
          end
        else
          csv.add_row(values)
        end
      end
    end
  end


  ###########  LOG WEB_ACT EXPORT  ###########
  #Call: ActCsvTool.new.log_act_webs_export
  def log_act_webs_export
    export = @user.exports.create(export_date: @export_date, file_name: @file_name)
    act_activities = @user.act_activities.where(act_id: [@acts.pluck(:id)])
    act_activities.update_all(export_id: export.id)

    webs = @acts.map {|act| act.webs }&.flatten&.uniq
    web_activities = @user.web_activities.where(web_id: [webs.pluck(:id)])
    web_activities.update_all(export_id: export.id)
  end


end
