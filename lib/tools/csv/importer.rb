module Importer

  ############## BEST CSV IMPORT METHOD #####################
  # RESTORE BACKUP METHODS BELOW - VERY QUICK PROCESS !!!
  # Re-Imports previously exported, formatted CSVs w/ ids, joins, assoc.
  # Imports CSV from: db/csv/backups/file_name.csv
  ###########################################################


  #CALL: CsvTool.new.restore_all_backups
  def restore_all_backups
    db_table_list = get_db_table_list
    db_table_list_hashes = db_table_list.map do |table_name|
      { model: table_name.classify.constantize, plural_model_name: table_name.pluralize }
    end

    db_table_list_hashes.each do |hash|
      hash[:model].delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!(hash[:plural_model_name])
    end

    db_table_list_hashes.each do |hash|
      restore_backup(hash[:model], "#{hash[:plural_model_name]}.csv")
    end

    ######### Reset PK Sequence #########
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end

  end


  # Call: CsvTool.new.restore_backup(Phone, 'Phones.csv')
  def restore_backup(model, file_name)
    @file_path = "#{@backups_dir_path}/#{file_name}"
    parse_csv
    @headers.map!(&:to_sym)
    model.import(@headers, @rows, validate: false)
    completion_msg(model, file_name)
  end



  ############# WORST CSV IMPORT METHOD BELOW #############
  # IMPORT SEED METHODS BELOW - BIG PROCESS!!
  # Imports Raw Data files, which runs through extensive validations.
  # Imports CSV from: db/csv/seeds/file_name.csv
  ##########################################################


  #CALL: CsvTool.new.import_all_seed_files
  def import_all_seed_files
    Migrator.new.reset_pk_sequence
    CsvTool.new.import_uni_seeds('uni_web', '1_valid_uni_webs.csv')
    CsvTool.new.import_uni_seeds('uni_web', '2_archived_uni_webs.csv')
    CsvTool.new.import_uni_seeds('uni_web', '3_links_texts_uni_webs.csv')

    CsvTool.new.import_uni_seeds('uni_account', '4_crm_uni_accounts.csv')
    CsvTool.new.import_uni_seeds('uni_account', '5_indexers_uni_accounts.csv')
    CsvTool.new.import_uni_seeds('uni_account', '6_locations_uni_accounts.csv')

    CsvTool.new.import_uni_seeds('uni_contact', '7_uni_contacts.csv')

    CsvTool.new.import_standard_seeds('who', '8_whos.csv')
    CsvTool.new.import_standard_seeds('brand', '9_brands.csv')
    CsvTool.new.import_standard_seeds('term', '10_terms.csv')
  end


  ########## UNI SEED IMPORT BELOW ##########
  #CALL: CsvTool.new.import_uni_seeds('uni_web', '1_valid_uni_webs.csv')
  #CALL: CsvTool.new.import_uni_seeds('uni_web', '2_archived_uni_webs.csv')
  #CALL: CsvTool.new.import_uni_seeds('uni_web', '3_links_texts_uni_webs.csv')

  #CALL: CsvTool.new.import_uni_seeds('uni_account', '4_crm_uni_accounts.csv')
  #CALL: CsvTool.new.import_uni_seeds('uni_account', '5_indexers_uni_accounts.csv')
  #CALL: CsvTool.new.import_uni_seeds('uni_account', '6_locations_uni_accounts.csv')
  #CALL: CsvTool.new.import_uni_seeds('uni_account', '7_whos_uni_accounts.csv')

  #CALL: CsvTool.new.import_uni_seeds('uni_contact', '8_uni_contacts.csv')

  #CALL: CsvTool.new.import_uni_seeds('uni_contact', '8_uni_contacts_blank.csv')


  def import_uni_seeds(model_name, file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"
    model = model_name.classify.constantize
    plural_model_name = model_name.pluralize
    custom_migrate_method = "migrate_#{plural_model_name}"
    parse_csv
    objs = []

    @clean_csv_hashes.each do |clean_csv_hash|
      clean_csv_hash = clean_csv_hash.stringify_keys
      clean_csv_hash.delete_if { |key, value| value.blank? } if !clean_csv_hash.empty?
      uni_hsh = validate_hsh(model.column_names, clean_csv_hash)
      objs << model.new(uni_hsh)
    end

    model.import(objs)
    puts "\nSleep(3) - Complete: model.import(objs)\n#{model_name}, #{file_name}"
    sleep(3)

    Migrator.new.send(custom_migrate_method)  ### NEED TO WORK ON THIS!!!
    puts "\nSleep(3) - Complete: Migrator.new.#{custom_migrate_method}\n#{file_name}"
    sleep(3)

    completion_msg(model, file_name)
  end


  ########## STANDARD SEED IMPORT BELOW ##########
  # CsvTool.new.import_standard_seeds('brand', '9_brands.csv')
  # CsvTool.new.import_standard_seeds('term', '10_terms.csv')

  def import_standard_seeds(model_name, file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"
    model = model_name.classify.constantize
    plural_model_name = model_name.pluralize
    custom_migrate_method = "migrate_#{plural_model_name}"

    parse_csv
    objs = []
    @clean_csv_hashes.each do |clean_csv_hash|
      clean_csv_hash = clean_csv_hash.stringify_keys
      clean_csv_hash.delete_if { |key, value| value.blank? } if !clean_csv_hash.empty?
      new_hsh = validate_hsh(model.column_names, clean_csv_hash)

      obj_exists = model.exists?(new_hsh) if new_hsh.present?
      obj = model.new(new_hsh) if !obj_exists
      objs << obj if obj
    end

    model.import(objs)
    puts "\nSleep(3) - Complete: model.import(objs)\n#{model_name}, #{file_name}"
    sleep(3)

    completion_msg(model, file_name)
  end


end
