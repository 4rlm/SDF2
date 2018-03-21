module ExcelImport
  #
  # ############## BEST Excel IMPORT METHOD #####################
  # # RESTORE BACKUP METHODS BELOW - VERY QUICK PROCESS !!!
  # # Re-Imports previously exported, formatted Excels w/ ids, joins, assoc.
  # # Imports Excel from: db/Excel/backups/file_name.Excel
  # ###########################################################
  #
  #
  # #CALL: ExcelTool.new.restore_all_backups
  # def restore_all_backups
  #   db_table_list = get_db_table_list
  #
  #   db_table_list_hashes = db_table_list.map do |table_name|
  #     { model: table_name.classify.constantize, plural_model_name: table_name.pluralize }
  #   end
  #
  #   db_table_list_hashes.each do |hsh|
  #     hsh[:model].delete_all
  #     ActiveRecord::Base.connection.reset_pk_sequence!(hsh[:plural_model_name])
  #   end
  #
  #   db_table_list_hashes.each do |hsh|
  #     restore_backup(hsh[:model], "#{hsh[:plural_model_name]}.Excel")
  #   end
  #
  #   ######### Reset PK Sequence #########
  #   ActiveRecord::Base.connection.tables.each do |t|
  #     ActiveRecord::Base.connection.reset_pk_sequence!(t)
  #   end
  #
  # end
  #
  #
  # # Call: ExcelTool.new.restore_backup(User, 'Users.Excel')
  # # Call: ExcelTool.new.restore_backup(Cont, 'Conts.Excel')
  #
  # # Call: ExcelTool.new.restore_backup(WebBrand, 'WebBrands.Excel')
  # # Call: ExcelTool.new.restore_backup(Who, 'Whos.Excel')
  #
  # # Call: ExcelTool.new.restore_backup(Brand, 'Brands.Excel')
  # # Call: ExcelTool.new.restore_backup(Template, 'Templates.Excel')
  #
  # def restore_backup(model, file_name)
  #   @file_path = "#{@backups_dir_path}/#{file_name}"
  #   parse_Excel
  #   @headers.map!(&:to_sym)
  #   model.import(@headers, @rows, validate: false)
  #   completion_msg(model, file_name)
  # end
  #
  #
  #
  # ############# WORST Excel IMPORT METHOD BELOW #############
  # # IMPORT SEED METHODS BELOW - BIG PROCESS!!
  # # Imports Raw Data files, which runs through extensive validations.
  # # Imports Excel from: db/Excel/seeds/file_name.Excel
  # ##########################################################
  #
  #
  # #CALL: ExcelTool.new.import_all_seed_files
  # def import_all_seed_files
  #   Mig.new.reset_pk_sequence
  #
  #   ExcelTool.new.import_uni_seeds('uni_act', 'cop_formated.Excel')
  #
  #   # ExcelTool.new.import_uni_seeds('uni_act', '1_acts_top_150.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_act', '2_wards_500.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_act', '3_acts_cop.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_act', '4_acts_sfdc.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_act', '5_acts_scraped.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_act', '6_acts_geo_locations.Excel')
  #
  #
  #   ########## UNI SEED IMPORT BELOW ##########
  #   # ExcelTool.new.import_uni_seeds('uni_web', '1_valid_uni_webs.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_web', '2_archived_uni_webs.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_web', '3_links_texts_uni_webs.Excel')
  #   #
  #   # ExcelTool.new.import_uni_seeds('uni_act', '4_crm_uni_acts.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_act', '5_indexers_uni_acts.Excel')
  #   # ExcelTool.new.import_uni_seeds('uni_act', '6_locations_uni_acts.Excel')
  #   #
  #   # ExcelTool.new.import_uni_seeds('uni_cont', '7_uni_conts.Excel')
  #   #
  #   # ########## STANDARD SEED IMPORT BELOW ##########
  #   # ExcelTool.new.import_standard_seeds('who', '8_whos.Excel')
  #   # ExcelTool.new.import_standard_seeds('brand', '9_brands.Excel')
  #   # ExcelTool.new.import_standard_seeds('term', '10_terms.Excel')
  # end
  #
  #
  # ########## UNI SEED IMPORT BELOW ##########
  # # ExcelTool.new.import_uni_seeds('uni_act', '1_cops.Excel')
  # # ExcelTool.new.import_uni_seeds('uni_act', '03_crm_uni_acts.Excel')
  #
  # def import_uni_seeds(model_name, file_name)
  #   @file_path = "#{@seeds_dir_path}/#{file_name}"
  #   model = model_name.classify.constantize
  #   plural_model_name = model_name.pluralize
  #   custom_migrate_method = "migrate_#{plural_model_name}"
  #   parse_Excel
  #   objs = []
  #   puts @clean_Excel_hashes.count
  #
  #   @clean_Excel_hashes.each do |clean_Excel_hsh|
  #     clean_Excel_hsh = clean_Excel_hsh.stringify_keys
  #     clean_Excel_hsh.delete_if { |key, value| value.blank? } if !clean_Excel_hsh.empty?
  #     uni_hsh = val_hsh(model.column_names, clean_Excel_hsh)
  #     objs << model.new(uni_hsh)
  #   end
  #
  #   model.import(objs)
  #   puts "\nSleep(3) - Complete: model.import(objs)\n#{model_name}, #{file_name}"
  #   sleep(3)
  #
  #   Mig.new.send(custom_migrate_method)  ### NEED TO WORK ON THIS!!!
  #   puts "\nSleep(3) - Complete: Mig.new.#{custom_migrate_method}\n#{file_name}"
  #   sleep(3)
  #
  #   completion_msg(model, file_name)
  # end
  #
  #
  # ########## STANDARD SEED IMPORT BELOW ##########
  #
  # def import_standard_seeds(model_name, file_name)
  #   @file_path = "#{@seeds_dir_path}/#{file_name}"
  #   model = model_name.classify.constantize
  #   plural_model_name = model_name.pluralize
  #   custom_migrate_method = "migrate_#{plural_model_name}"
  #
  #   parse_Excel
  #   objs = []
  #   @clean_Excel_hashes.each do |clean_Excel_hsh|
  #     clean_Excel_hsh = clean_Excel_hsh.stringify_keys
  #     clean_Excel_hsh.delete_if { |key, value| value.blank? } if !clean_Excel_hsh.empty?
  #     new_hsh = val_hsh(model.column_names, clean_Excel_hsh)
  #
  #     obj_exists = model.exists?(new_hsh) if new_hsh.present?
  #     obj = model.new(new_hsh) if !obj_exists
  #     objs << obj if obj
  #   end
  #
  #   model.import(objs)
  #   puts "\nSleep(3) - Complete: model.import(objs)\n#{model_name}, #{file_name}"
  #   sleep(3)
  #
  #   completion_msg(model, file_name)
  # end
  #

end
