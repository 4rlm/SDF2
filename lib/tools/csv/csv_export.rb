module CsvExport

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
  ## CALL: CsvTool.new.export_web_acts('query')
  def export_web_acts(query)
    query = Web.where(cs_sts: 'Valid')[-1..-1] ## Just for testing - Query should be passed in.
    file_name = "web_acts_#{@current_time}.csv"
    path_and_file = "#{@exports_path}/#{file_name}"

    web_cols = %w(id url temp_name)
    brand_cols = %w(brand_name)
    act_cols = %w(act_name gp_id lat lon street city state zip phone adr_changed act_changed)

    CSV.open(path_and_file, "wb") do |csv|
      csv.add_row(web_cols + brand_cols + act_cols)

      query.each do |web|
        values = web.attributes.slice(*web_cols).values
        values << web.brands&.map { |brand| brand&.brand_name }&.sort&.uniq&.join(', ')

        if web.acts.any?
          web.acts.each do |act|
            csv.add_row(values += act.attributes.slice(*act_cols).values)
          end
        else
          csv.add_row(values)
        end

      end
    end
  end
  ###########################################################















  ########## ADMIN BACK-END BACKUP METHODS BELOW #############
  # Exports CSV to: db/csv/backups/file_name.csv
  # CSVs can be re-imported via CsvTool.new.restore_all_backups
  ###########################################################

  # CALL: CsvTool.new.backup_entire_db
  def backup_entire_db
    db_table_list = get_db_table_list
    db_table_list.each do |table_name|
      model = table_name.constantize
      file_name = "#{table_name.pluralize}.csv"
      CsvTool.new.backup_csv(model, file_name)
    end
  end

  #CALL: CsvTool.new.backup_csv(User, 'Users.csv')
  def backup_csv(model, file_name)
    path_and_file = "#{@backups_path}/#{file_name}"
    CSV.open(path_and_file, "wb") do |csv|
      csv << model.attribute_names
      model.all.each { |r| csv << r.attributes.values }
    end
  end


end
