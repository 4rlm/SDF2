class ContCsvTool

  def initialize(params, current_user)
    @params = params
    @user = current_user

    if params[:q].present?
      @conts = Cont.ransack(params[:q]).result(distinct: true).includes(:acts, :web, :brands)
    elsif params[:tally_scope].present?
      @conts = Cont.send(params[:tally_scope])
    end

    @export_date = Time.now
    @file_name = "Cont_#{@export_date.strftime("%m_%d_%I_%M_%S")}.csv"
    # @path_and_file = "./public/downloads/#{@file_name}"
  end


  def start_cont_web_csv_and_log
    cont_web_to_csv
    # log_cont_web_export
  end

  def save_cont_queries(q_name)
    query = @user.queries.find_or_initialize_by(mod_name: 'Cont', q_name: q_name)
    query.params = @params
    query.row_count = @conts.count
    query.save
  end


  ############  WEB_ACTS EXPORT  ############
  def cont_web_to_csv
    cont_cols = %w(id web_id first_name last_name job_title job_desc email phone cs_date email_changed cont_changed job_changed created_at cx_date)
    web_cols = %w(url url_sts cop temp_name cs_sts web_changed wx_date)
    brand_cols = %w(brand_name)
    export = Export.new

    CSV.generate(options = {}) do |csv|
      csv.add_row(cont_cols + web_cols + brand_cols)
      @conts.each do |cont|
        values = cont.attributes.slice(*cont_cols).values
        values += cont.web.attributes.slice(*web_cols).values
        values << cont.web.brands&.map { |brand| brand&.brand_name }&.sort&.uniq&.join(', ')
        csv.add_row(values)
      end

      file = StringIO.new(csv.string)
      export.csv = file
      export.csv.instance_write(:content_type, 'text/csv')
      export.csv.instance_write(:file_name, @file_name)
      export.user = @user
      export.export_date = @export_date
      export.file_name = @file_name
      export.save!
    end

  end


  ###########  LOG CONT_WEB EXPORT  ###########
  def log_cont_web_export
    export = @user.exports.create(export_date: @export_date, file_name: @file_name)
    cont_activities = @user.cont_activities.where(cont_id: [@conts.pluck(:id)])
    cont_activities.update_all(export_id: export.id)

    web_activities = @user.web_activities.where(web_id: [@conts.pluck(:web_id)])
    web_activities.update_all(export_id: export.id)
  end


end
