# To Reset DB PK ID:
# model.delete_all #=> UniWeb.delete_all
# ActiveRecord::Base.connection.reset_pk_sequence!('uni_webs')

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
    CsvTool.new.import_seed_uni_webs('1_valid_uni_webs.csv')
    CsvTool.new.import_seed_uni_webs('2_archived_uni_webs.csv')
    CsvTool.new.import_seed_uni_webs('3_links_texts_uni_webs.csv')

    CsvTool.new.import_seed_uni_accounts('4_crm_uni_accounts.csv')
    CsvTool.new.import_seed_uni_accounts('5_indexers_uni_accounts.csv')
    CsvTool.new.import_seed_uni_accounts('6_locations_uni_accounts.csv')
    CsvTool.new.import_seed_uni_accounts('7_whos_uni_accounts.csv')

    CsvTool.new.import_seed_uni_contacts('8_uni_contacts.csv')

    CsvTool.new.import_seed_brands('9_brands.csv') # in_host_pos
    CsvTool.new.import_seed_terms('10_terms.csv') # indexer_terms
  end
  ### ABOVE METHOD CALLS EACH OF THE METHODS BELOW ###


  ### BELOW IMPORT SEED METHODS CAN BE RUN IN ISOLATION ###
  # Data is Imported to a Temporary Table, then migrated.
  # 1) import_seed_uni_webs => UniWeb Table => Migrator.new.migrate_uni_webs
  # 2) import_seed_uni_accounts => UniAccount Table => Migrator.new.migrate_uni_accounts
  # 3) import_seed_uni_contacts => UniContact Table => Migrator.new.migrate_uni_contacts
  # 4) import_seed_brands => Brand Table (directly)
  # 5) import_seed_terms => Term Table (directly)



  #CALL: CsvTool.new.import_seed_uni_webs('1_valid_uni_webs.csv')
  #CALL: CsvTool.new.import_seed_uni_webs('2_archived_uni_webs.csv')
  #CALL: CsvTool.new.import_seed_uni_webs('3_links_texts_uni_webs.csv')
  def import_seed_uni_webs(file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"

    parse_csv
    uni_webs = []
    @clean_csv_hashes.each do |clean_csv_hash|
      clean_csv_hash = clean_csv_hash.stringify_keys
      clean_csv_hash.delete_if { |key, value| value.blank? } if !clean_csv_hash.empty?
      uni_web_hash = validate_hash(UniWeb.column_names, clean_csv_hash)
      uni_webs << UniWeb.new(uni_web_hash)
    end

    UniWeb.import(uni_webs)
    puts "Sleep(3) - Complete: UniWeb.import(uni_webs)"
    sleep(3)

    Migrator.new.migrate_uni_webs
    puts "Sleep(3) - Complete: Migrator.new.migrate_uni_webs"
    sleep(3)

    completion_msg(UniWeb, file_name)
  end


  #CALL: CsvTool.new.import_seed_uni_accounts('4_crm_uni_accounts.csv')
  #CALL: CsvTool.new.import_seed_uni_accounts('5_indexers_uni_accounts.csv')
  #CALL: CsvTool.new.import_seed_uni_accounts('6_locations_uni_accounts.csv')
  #CALL: CsvTool.new.import_seed_uni_accounts('7_whos_uni_accounts.csv')
  def import_seed_uni_accounts(file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"

    parse_csv
    accounts = []
    @clean_csv_hashes.each do |clean_csv_hash|
      clean_csv_hash = clean_csv_hash.stringify_keys
      account_hash = validate_hash(UniAccount.column_names, clean_csv_hash)
      account = UniAccount.new(account_hash)
      accounts << account
    end

    UniAccount.import(accounts)
    puts "Sleep(3) - Complete: UniAccount.import(accounts)"
    sleep(3)

    Migrator.new.migrate_uni_accounts
    puts "Sleep(3) - Complete: Migrator.new.migrate_uni_accounts"
    sleep(3)

    completion_msg(UniAccount, file_name)
  end


  #CALL: CsvTool.new.import_seed_uni_contacts('8_uni_contacts.csv')
  def import_seed_uni_contacts(file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"

    parse_csv
    contacts = []
    @clean_csv_hashes.each do |clean_csv_hash|
      clean_csv_hash = clean_csv_hash.stringify_keys
      contact_hash = validate_hash(UniContact.column_names, clean_csv_hash)
      contact = UniContact.new(contact_hash)
      contacts << contact
    end

    UniContact.import(contacts)
    puts "Sleep(3) - Complete: UniContact.import(contacts)"
    sleep(3)

    Migrator.new.migrate_uni_contacts
    puts "Sleep(3) - Complete: Migrator.new.migrate_uni_contacts"
    sleep(3)

    completion_msg(UniContact, file_name)
  end


  #CALL: CsvTool.new.import_seed_brands('9_brands.csv') # in_host_pos
  def import_seed_brands(file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"

    parse_csv
    brands = []
    @clean_csv_hashes.each do |clean_csv_hash|
      clean_csv_hash = clean_csv_hash.stringify_keys
      brand_hash = validate_hash(Brand.column_names, clean_csv_hash)

      brand_obj_exists = Brand.exists?(brand_hash)
      new_brand_obj = Brand.new(brand_hash) if !brand_obj_exists
      brands << new_brand_obj if new_brand_obj
    end

    Brand.import(brands)
    puts "Sleep(3) - Complete: Brand.import(brands)"
    sleep(3)

    completion_msg(Brand, file_name)
  end


  #CALL: CsvTool.new.import_seed_terms('10_terms.csv') # indexer_terms
  def import_seed_terms(file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"

    parse_csv
    terms = []
    @clean_csv_hashes.each do |clean_csv_hash|
      clean_csv_hash = clean_csv_hash.stringify_keys
      term_hash = validate_hash(Term.column_names, clean_csv_hash)

      term_obj_exists = Term.exists?(term_hash)
      new_term_obj = Term.new(term_hash) if !term_obj_exists
      terms << new_term_obj if new_term_obj
    end

    Term.import(terms)
    puts "Sleep(3) - Complete: Term.import(terms)"
    sleep(3)

    completion_msg(Term, file_name)
  end


end
