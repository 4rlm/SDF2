module Importer

  def self.run_importer
    puts "Welcome to Importer Module"
    binding.pry
  end


  # Call: CsvTool.new.restore_backup(Phone, 'Phones.csv')
  def restore_backup(model, file_name)
    @file_path = "#{@backups_dir_path}/#{file_name}"
    parse_csv
    @headers.map!(&:to_sym)
    model.import(@headers, @rows, validate: false)
    completion_msg(model, file_name)
  end



  ### IMPORT SEED METHODS BELOW ###

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

  ## NEED TO CREATE UNI_WEB MIGRATOR TOO.

  #CALL: CsvTool.new.import_seed_uni_webs('1_valid_uni_webs.csv')
  #CALL: CsvTool.new.import_seed_uni_webs('2_archived_uni_webs.csv')
  #CALL: CsvTool.new.import_seed_uni_webs('3_links_texts_uni_webs.csv')
  def import_seed_uni_webs(file_name)
    @file_path = "#{@seeds_dir_path}/#{file_name}"

    parse_csv
    uni_web = []
    @clean_csv_hashes.each do |clean_csv_hash|
      clean_csv_hash = clean_csv_hash.stringify_keys
      binding.pry

      clean_csv_hash.delete_if { |key, value| value.blank? } if !clean_csv_hash.empty?
      binding.pry

      uni_web_hash = validate_hash(UniWeb.column_names, clean_csv_hash)
      binding.pry

      uni_web_obj = UniWeb.new(uni_web_hash)
      binding.pry

      uni_web << uni_web_obj
      binding.pry
    end

    binding.pry
    UniWeb.import(uni_web)
    binding.pry

    Migrator.new.migrate_uni_webs
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
    Migrator.new.migrate_uni_accounts
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
    Migrator.new.migrate_uni_contacts
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
    completion_msg(Term, file_name)
  end



  ############################################






  ## ORIGINAL BELOW.  Will Replace with next one.
  ## DELETE AFTER TESTING TRIAL ABOVE.

  #CALL: # CsvTool.new.import_seed_webs('1_clean_urls.csv')
  # def import_seed_webs(file_name)
  #   @file_path = "#{@seeds_dir_path}/#{file_name}"
  #
  #   parse_csv
  #   webs = []
  #   @clean_csv_hashes.each do |clean_csv_hash|
  #     clean_csv_hash = clean_csv_hash.stringify_keys
  #     web_hash = validate_hash(Web.column_names, clean_csv_hash)
  #
  #     url = web_hash['url']
  #     redirect_url = web_hash['url_redirect_id'] ## Grabs url in id column to replace with id number (below)
  #     redirect_url_obj = Web.find_by(url: redirect_url) if redirect_url
  #     web_hash['url_redirect_id'] = redirect_url_obj.id if (redirect_url && redirect_url_obj)
  #     url_obj = Web.find_by(url: url)
  #
  #     if url_obj
  #       Migrator.new.update_obj_if_changed(web_hash, url_obj)
  #     else
  #       url_obj = Web.new(web_hash)
  #       webs << url_obj
  #     end
  #
  #   end
  #   Web.import(webs) if !webs.empty?
  #   completion_msg(Web, file_name)
  # end

  ## BELOW TRIAL. WILL REPLACE ABOVE WHEN COMPLETE.
  ## TRIAL - TEST, IMPORT WEBS AND PARSE LINKS.







  #
  # def validate_hash(cols, hash)
  #   # cols.map!(&:to_sym)
  #   keys = hash.keys
  #   keys.each { |key| hash.delete(key) if !cols.include?(key) }
  #   return hash
  # end
  #
  #
  # def parse_csv
  #   counter = 0
  #   error_row_numbers = []
  #   @clean_csv_hashes = []
  #   @headers = []
  #   @rows = []
  #
  #   File.open(@file_path).each do |line|
  #     begin
  #       line = line&.gsub(/\s/, ' ')&.strip
  #
  #       CSV.parse(line) do |row|
  #         if counter > 0
  #           @clean_csv_hashes << row_to_hash(row)
  #           @rows << row
  #         else
  #           @headers = row
  #         end
  #         counter += 1
  #       end
  #     rescue => er
  #       error_row_numbers << {"#{counter}": "#{er.message}"}
  #       counter += 1
  #       next
  #     end
  #   end
  #
  #   error_report(error_row_numbers)
  #   # return @clean_csv_hashes
  # end
  #
  #
  # def error_report(error_row_numbers)
  #   puts "\nCSV data ready to import.\nCSV Errors Found: #{error_row_numbers.length}\nRows containing errors (if any) will be skipped.\nErrors on the lines listed below (if any):"
  #
  #   error_row_numbers.each_with_index { |hash, i| puts "#{i+1}) Row #{hash.keys[0]}: #{hash.values[0]}." }
  # end
  #
  # def row_to_hash(row)
  #   h = Hash[@headers.zip(row)]
  #   h.symbolize_keys
  # end


end
