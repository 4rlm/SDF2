class ActCsvTool

  def generate_query(params)
    if params[:q].present?
      acts = Act.ransack(params[:q]).result(distinct: true)
    elsif params[:tally_scope].present?
      acts = Act.send(params[:tally_scope])
    end
  end

  def start_act_webs_csv_and_log(params, current_user)
    export = Export.new
    acts = generate_query(params)
    act_webs_to_csv(current_user, export, acts)
    log_act_webs_export(current_user, export, acts)
  end

  def save_act_queries(q_name, params, current_user)
    acts = generate_query(params)
    query = current_user.queries.find_or_initialize_by(mod_name: 'Act', q_name: q_name)
    query.params = params
    query.row_count = acts.count
    query.save
  end

  ############  WEB_ACTS EXPORT  ############
  def act_webs_to_csv(current_user, export, acts)
    act_cols = %w(id act_name gp_id gp_sts lat lon street city state zip phone act_changed adr_changed ax_date)
    brand_cols = %w(brand_name)
    web_cols = %w(url fwd_url url_sts cop temp_name cs_sts created_at web_changed wx_date)

    export_date = Time.now
    file_name = "Act_#{export_date.strftime("%m_%d_%I_%M_%S")}.csv"

    CSV.generate(options = {}) do |csv|
      csv.add_row(act_cols + brand_cols + web_cols)
      acts.each do |act|
        values = act.attribute_vals(act_cols)
        values << act.brands_to_string

        if act.webs.any?
          act.webs.each do |web|
            csv.add_row(values + web.attribute_vals(web_cols))
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
  #Call: ActCsvTool.new.log_act_webs_export
  def log_act_webs_export(current_user, export, acts)
    act_activities = current_user.act_activities.by_act(acts)
    act_activities.update_all(export_id: export)

    webs = Web.by_act(acts)
    web_activities = current_user.web_activities.by_web(webs)
    web_activities.update_all(export_id: export)
  end

end
