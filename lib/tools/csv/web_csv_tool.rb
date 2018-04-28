class WebCsvTool

  def initialize(params, current_user)
    @params = params
    @user = current_user

    if params[:q].present?
      @webs = Web.ransack(params[:q]).result(distinct: true).includes(:acts, :conts, :brands)
    elsif params[:tally_scope].present?
      @webs = Web.send(params[:tally_scope])
    end

    @export_date = Time.now
    @file_name = "Web_#{@export_date.strftime("%m_%d_%I_%M_%S")}.csv"
    @export = Export.new
  end


  def start_web_acts_csv_and_log
    web_acts_to_csv
    log_web_acts_export
  end

  def save_web_queries(q_name)
    query = @user.queries.find_or_initialize_by(mod_name: 'Web', q_name: q_name)
    query.params = @params
    query.row_count = @webs.count
    query.save
  end


  ############  WEB_ACTS EXPORT  ############
  def web_acts_to_csv
    web_cols = %w(id url fwd_url url_sts cop temp_name cs_sts created_at web_changed wx_date)
    brand_cols = %w(brand_name)
    act_cols = %w(act_name gp_id gp_sts lat lon street city state zip phone act_changed adr_changed ax_date)

    CSV.generate(options = {}) do |csv|
      csv.add_row(web_cols + brand_cols + act_cols)
      @webs.each do |web|
        values = web.attributes.slice(*web_cols).values
        values << web.brands&.map { |brand| brand&.brand_name }&.sort&.uniq&.join(', ')

        if web.acts.any?
          web.acts.each do |act|
            csv.add_row(values + act.attributes.slice(*act_cols).values)
          end
        else
          csv.add_row(values)
        end
      end

      file = StringIO.new(csv.string)
      @export.csv = file
      @export.csv.instance_write(:content_type, 'text/csv')
      @export.csv.instance_write(:file_name, @file_name)
      @export.user = @user
      @export.export_date = @export_date
      @export.file_name = @file_name
      @export.save!
    end


  end


  ###########  LOG WEB_ACT EXPORT  ###########
  #Call: WebCsvTool.new.log_web_acts_export
  def log_web_acts_export
    # export = @user.exports.create(export_date: @export_date, file_name: @file_name)
    web_activities = @user.web_activities.where(web_id: [@webs.pluck(:id)])
    web_activities.update_all(export_id: @export.id)

    acts = @webs.map {|web| web.acts }&.flatten&.uniq
    act_activities = @user.act_activities.where(act_id: [acts.pluck(:id)])
    act_activities.update_all(export_id: @export.id)
  end


end
