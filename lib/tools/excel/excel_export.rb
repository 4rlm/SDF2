module ExcelExport
  #
  # ################ !!! CAUTION !!! #########################
  # # THESE METHODS WILL OVER-WRITE PRIOR Excel BACKUPS !!
  # # Exports Excel to: db/Excel/backups/file_name.Excel
  # # Excels can be re-imported via ExcelTool.new.restore_all_backups
  # ###########################################################
  #
  #
  # # CALL: ExcelTool.new.backup_entire_db
  # def backup_entire_db
  #   # db_table_list = ["Link", "Linking", "Text", "Texting"]
  #   db_table_list = get_db_table_list
  #
  #   db_table_list.each do |table_name|
  #     model = table_name.constantize
  #     file_name = "#{table_name.pluralize}.Excel"
  #     ExcelTool.new.backup_Excel(model, file_name)
  #   end
  # end
  #
  #
  # #CALL: ExcelTool.new.backup_Excel(User, 'Users.Excel')
  #
  # #CALL: ExcelTool.new.backup_Excel(Tally, 'Tallies.Excel')
  # #CALL: ExcelTool.new.backup_Excel(Dealer, 'Dealers.Excel')
  # #CALL: ExcelTool.new.backup_Excel(Crma, 'Crmas.Excel')
  # #CALL: ExcelTool.new.backup_Excel(Crmc, 'Crmcs.Excel')
  # def backup_Excel(model, file_name)
  #   backups_file_path = "#{@backups_dir_path}/#{file_name}"
  #   Excel.open(backups_file_path, "wb") do |Excel|
  #     Excel << model.attribute_names
  #     model.all.each { |r| Excel << r.attributes.values }
  #   end
  # end
  #
  #
  # def download_Excel
  #   Excel.generate do |Excel|
  #     Excel << @model.attribute_names
  #     @model.all.each { |r| Excel << r.attributes.values }
  #   end
  # end
  #

end
