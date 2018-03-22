module CsvServExport

  ## CALL: CsvServTool.new.greeter
  def greeter
    puts "Hi"
  end

  def download_csv
    CSV.generate do |csv|
      csv << @model.attribute_names
      @model.all.each { |r| csv << r.attributes.values }
    end
  end



  ########## USER FRONT-END BACKUP METHODS BELOW #############
  # Exports CSV to: db/csv/exports/file_name.csv
  ###########################################################


  ###########################################################
  ## FILTERED COLS: SAVES CSV, NOT GENERATE!
  ## PERFECT! - INCLUDES [WEB, BRANDS, ACTS]!
  ## CALL: CsvServTool.new.export_web_acts('query')
  def export_web_acts(webs)
    webs = Web.where(cs_sts: 'Valid')[-100..-1] ## Just for testing - Query should be passed in.
    file_name = "web_acts_#{@current_time.strftime("%Y%m%d%I%M%S")}.csv"
    path_and_file = "#{@exports_path}/#{file_name}"

    web_cols = %w(id url fwd_url url_sts cop temp_name cs_sts created_at web_changed wx_date)
    brand_cols = %w(brand_name)
    act_cols = %w(act_name gp_id gp_sts lat lon street city state zip phone act_changed adr_changed ax_date)

    CSV.open(path_and_file, "wb") do |csv|
      csv.add_row(web_cols + brand_cols + act_cols)

      webs.each do |web|
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
  ###########################################################

  ###########################################################

  ## Method for Testing export_cont_web.  Would normally be run by user on front-end based on Favorites.
  def testing_export_cont_web
    conts = Cont.where("job_title LIKE '%General%'")[-100..-1] ## Just for testing - Query should be passed in.
    user_id = 1
    export_cont_web(conts)

    binding.pry
    ## Add export log to Export Table.
    log_export_cont_web(query, user_id)
    binding.pry
  end

  ## FILTERED COLS: SAVES CSV, NOT GENERATE!
  ## PERFECT! - INCLUDES [CONTS, WEB, BRANDS]!
  ## CALL: CsvServTool.new.export_cont_web('query')
  def export_cont_web(conts)
    file_name = "cont_web_#{@current_time.strftime("%Y%m%d%I%M%S")}.csv"
    path_and_file = "#{@exports_path}/#{file_name}"

    cont_cols = %w(id web_id first_name last_name job_title job_desc email phone cs_date email_changed cont_changed job_changed created_at cx_date)
    web_cols = %w(url url_sts cop temp_name cs_sts web_changed wx_date)
    brand_cols = %w(brand_name)

    CSV.open(path_and_file, "wb") do |csv|
      csv.add_row(cont_cols + web_cols + brand_cols)

      conts.each do |cont|
        values = cont.attributes.slice(*cont_cols).values
        values += cont.web.attributes.slice(*web_cols).values
        values << cont.web.brands&.map { |brand| brand&.brand_name }&.sort&.uniq&.join(', ')
        csv.add_row(values)
      end
    end
  end
  ###########################################################

  ###########################################################

  ## CALL: CsvServTool.new.log_export_cont_web('conts', 'user_id')
  def log_export_cont_web(conts, user_id)
    user = User.find(1)
    conts = Cont.where("job_title LIKE '%General%'")[-100..-1]

    cont_ids = conts.map(&:id)&.sort.uniq
    web_ids = conts.map(&:web_id)&.sort.uniq

    export_obj = Export.find_or_create_by(user: user, export_date: @current_time)
    export_obj.conts << conts

    webs = conts.map {|cont| cont.web }&.sort&.uniq
    export_obj.webs << webs

    binding.pry
  end
















  ########## ADMIN BACK-END BACKUP METHODS BELOW #############
  # Exports CSV to: db/csv/backups/file_name.csv
  # CSVs can be re-imported via CsvServTool.new.restore_all_backups
  ###########################################################

  # CALL: CsvServTool.new.backup_entire_db
  def backup_entire_db
    db_table_list = get_db_table_list
    db_table_list.each do |table_name|
      model = table_name.constantize
      file_name = "#{table_name.pluralize}.csv"
      CsvServTool.new.backup_csv(model, file_name)
    end
  end

  #CALL: CsvServTool.new.backup_csv(User, 'Users.csv')
  def backup_csv(model, file_name)
    path_and_file = "#{@backups_path}/#{file_name}"
    CSV.open(path_and_file, "wb") do |csv|
      csv << model.attribute_names
      model.all.each { |r| csv << r.attributes.values }
    end
  end


end
