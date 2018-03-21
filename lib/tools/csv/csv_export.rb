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
    backups_file_path = "#{@backups_path}/#{file_name}"
    CSV.open(backups_file_path, "wb") do |csv|
      csv << model.attribute_names
      model.all.each { |r| csv << r.attributes.values }
    end
  end


end
