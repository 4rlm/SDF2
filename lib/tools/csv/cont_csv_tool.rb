class ContCsvTool

  def generate_query(params)
    if params[:q].present?
      conts = Cont.ransack(params[:q]).result(distinct: true)
    elsif params[:tally_scope].present?
      conts = Cont.send(params[:tally_scope])
    end
  end


  def start_cont_web_csv_and_log(params, current_user)
    export = Export.new
    conts = generate_query(params)
    cont_web_to_csv(current_user, export, conts)
    log_cont_web_export(current_user, export, conts)
  end

  def save_cont_queries(q_name, params, current_user)
    conts = generate_query(params)
    query = current_user.queries.find_or_initialize_by(mod_name: 'Cont', q_name: q_name)
    query.params = params
    query.row_count = conts.count
    query.save
  end


  ############  WEB_ACTS EXPORT  ############
  def cont_web_to_csv(current_user, export, conts)
    cont_cols = %w(id web_id first_name last_name job_title job_desc email phone cs_date email_changed cont_changed job_changed created_at cx_date)
    web_cols = %w(url url_sts cop temp_name cs_sts web_changed wx_date)
    brand_cols = %w(brand_name)

    export_date = Time.now
    file_name = "Cont_#{export_date.strftime("%m_%d_%I_%M_%S")}.csv"

    CSV.generate(options = {}) do |csv|
      csv.add_row(cont_cols + web_cols + brand_cols)
      conts.each do |cont|
        values = cont.attribute_vals(cont_cols)
        values += cont.web.attribute_vals(web_cols)
        values << cont.web.brands_to_string
        csv.add_row(values)
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


  ###########  LOG CONT_WEB EXPORT  ###########
  def log_cont_web_export(current_user, export, conts)
    cont_activities = current_user.cont_activities.by_cont(conts)
    cont_activities.update_all(export_id: export)

    webs = Web.by_cont(conts)
    web_activities = current_user.web_activities.by_web(webs)
    web_activities.update_all(export_id: export)
  end


end
