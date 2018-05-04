class WebCsvTool

  def generate_query(params)
    if params[:q].present?
      webs = Web.ransack(params[:q]).result(distinct: true).includes(:acts, :conts, :brands)
    elsif params[:tally_scope].present?
      webs = Web.send(params[:tally_scope])
    end
  end


  def start_web_acts_csv_and_log(params, current_user)
    export = Export.new
    webs = generate_query(params)
    web_acts_to_csv(current_user, export, webs)
    log_web_acts_export(current_user, export, webs)
  end

  def save_web_queries(q_name, params, current_user)
    webs = generate_query(params)
    query = current_user.queries.find_or_initialize_by(mod_name: 'Web', q_name: q_name)
    query.params = params
    query.row_count = webs.count
    query.save
  end


  ############  WEB_ACTS EXPORT  ############
  def web_acts_to_csv(current_user, export, webs)
    web_cols = %w(id url fwd_url url_sts cop temp_name cs_sts created_at web_changed wx_date)
    brand_cols = %w(brand_name)
    act_cols = %w(act_name gp_id gp_sts lat lon street city state zip phone act_changed adr_changed ax_date)

    export_date = Time.now
    file_name = "Web_#{export_date.strftime("%m_%d_%I_%M_%S")}.csv"

    CSV.generate(options = {}) do |csv|
      csv.add_row(web_cols + brand_cols + act_cols)
      webs.each do |web|
        values = web.attribute_vals(web_cols)
        values << web.brands_to_string

        if web.acts.any?
          web.acts.each do |act|
            csv.add_row(values + act.attribute_vals(act_cols))
          end
        else
          csv.add_row(values)
        end
      end

      file = StringIO.new(csv.string)
      export.csv = file
      export.csv.instance_write(:content_type, 'text/csv')
      export.csv.instance_write(:file_name, file_name)
      export.user = current_user
      export.export_date = export_date
      export.file_name = file_name
      export.save!
    end

  end


  ###########  LOG WEB_ACT EXPORT  ###########
  def log_web_acts_export(current_user, export, webs)
    web_activities = current_user.web_activities.by_web(webs)
    web_activities.update_all(export_id: export)

    acts = Act.by_web(webs)
    act_activities = current_user.act_activities.by_act(acts)
    act_activities.update_all(export_id: export)
  end


end
