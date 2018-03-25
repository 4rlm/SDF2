class WebCsvTool

  def initialize(web_q, current_user)
    @web_q = web_q
    @user = current_user
    @webs = Web.ransack(@web_q).result(distinct: true).includes(:acts, :conts, :brands)

    @export_date = Time.now
    @file_name = "web_acts_#{@export_date.strftime("%Y%m%d%I%M%S")}.csv"
    @path_and_file = "./public/downloads/#{@file_name}"
  end


  def start_web_acts_csv_and_log
    web_acts_to_csv
    log_web_acts_export
  end

  def save_web_queries(q_name)
    query = @user.queries.find_or_initialize_by(mod_name: 'Web', q_name: q_name)
    query.q_hsh = @web_q
    query.save
  end


  ############  WEB_ACTS EXPORT  ############
  def web_acts_to_csv
    web_cols = %w(id url fwd_url url_sts cop temp_name cs_sts created_at web_changed wx_date)
    brand_cols = %w(brand_name)
    act_cols = %w(act_name gp_id gp_sts lat lon street city state zip phone act_changed adr_changed ax_date)

    CSV.open(@path_and_file, "wb") do |csv|
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
    end
  end


  ###########  LOG WEB_ACT EXPORT  ###########
  #Call: WebCsvTool.new.log_web_acts_export
  def log_web_acts_export
    export = @user.exports.create(export_date: @export_date, file_name: @file_name)

    @webs.each do |web|
      activity = @user.activities.find_or_initialize_by(mod_name: 'Web', mod_id: web.id)
      activity.export_id = export.id
      activity.save
    end

    acts = @webs.map {|web| web.acts }&.flatten&.uniq
    acts.each do |act|
      activity = @user.activities.find_or_initialize_by(mod_name: 'Act', mod_id: act.id)
      activity.export_id = export.id
      activity.save
    end

  end


end
