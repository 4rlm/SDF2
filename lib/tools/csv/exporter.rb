module Exporter

  def backup_entire_db
    #CALL: CsvToolMod::Export.backup_entire_db
    db_table_list = CsvToolMod.get_db_table_list
    # db_table_list = ["Link", "Linking", "Text", "Texting"]

    db_table_list.each do |table_name|
      model = table_name.constantize
      file_name = "#{table_name.pluralize}.csv"
      CsvTool.new.backup_csv(model, file_name)
    end
  end


  def backup_csv(model, file_name)
    backups_file_path = "#{@backups_dir_path}/#{file_name}"
    CSV.open(backups_file_path, "wb") do |csv|
      csv << model.attribute_names
      model.all.each { |r| csv << r.attributes.values }
    end
  end

  def download_csv
    CSV.generate do |csv|
      csv << @model.attribute_names
      @model.all.each { |r| csv << r.attributes.values }
    end
  end

end
