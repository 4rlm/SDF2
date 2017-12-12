# IMPORTANT: Works with /lib/migrators/uni_migrator.rb

# Notes:
# 1) CsvTool class calls CsvToolMod module.  Both files work together.
# 2) Note: Ensure config/application.rb extends autoload to concerns.

# EXPORT:
## Call: CsvToolMod::Export.backup_entire_db
## Call: CsvTool.new(Term, 'terms').backup_csv
## Call: CsvTool.new(Term, 'terms').download_csv


# IMPORT:
#CALL: CsvToolMod::Import.import_entire_seeds


###############
# @seeds_file_path = "#{@seeds_dir_path}/#{file_name}"
# @backups_file_path = "#{@backups_dir_path}/#{file_name}"


require 'csv'
require 'pry'

module CsvToolMod
  extend ActiveSupport::Concern

  module Export

    def self.backup_entire_db
      #CALL: CsvToolMod::Export.backup_entire_db
      Rails.application.eager_load!
      db_table_list = ActiveRecord::Base.descendants.map(&:name)
      removables = ['ApplicationRecord', 'UniContact', 'UniAccount']
      removables.each { |table| db_table_list.delete(table) }
      db_table_list.reverse!

      db_table_list.each do |table_name|
        model = table_name.constantize
        file_name = "#{table_name.pluralize}.csv"
        CsvTool.new.backup_csv(model, file_name)
      end

    end


    def backup_csv(model, file_name)
      # CsvTool.new.backup_csv(Term, 'X_terms.csv') # new
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


  module Import

    def self.import_entire_seeds
      #CALL: CsvToolMod::Import.import_entire_seeds

      ########### IMPORT: CURRENT VERSION ###########
      # Files should be stored in db/backups/... and not pushed to git (gitignore).  Saved locally only.
      # Copy and paste each of below into rails c terminal to import.
      # Will skip rows containing invalid non-utf-8 characters, but will provide error report first.

      CsvTool.new.import_seed_brands('8_brands.csv') # in_host_pos
      binding.pry

      CsvTool.new.import_seed_terms('7_terms.csv') # indexer_terms
      binding.pry

      CsvTool.new.import_seed_webs('1_clean_urls.csv')
      binding.pry
      
      CsvTool.new.import_seed_webs('2_redirects.csv')
      binding.pry

      CsvTool.new.import_seed_uni_accounts('3_indexers.csv')
      binding.pry

      CsvTool.new.import_seed_uni_accounts('4_locations.csv')
      binding.pry

      CsvTool.new.import_seed_uni_accounts('5_whos.csv')
      binding.pry

      CsvTool.new.import_seed_uni_accounts('6_core_accounts.csv')
      binding.pry

      CsvTool.new.import_seed_uni_contacts('9_contacts.csv')
      binding.pry

    end

    def completion_msg(model, file_name)
      puts "\n\n== Imported #{file_name} to #{model} table. ==\n\n"
      migration_report
    end


    def import_seed_brands(file_name)
      # CsvTool.new.import_seed_brands('8_brands.csv')
      @file_path = "#{@seeds_dir_path}/#{file_name}"
      clean_csv_hashes = iterate_csv_w_error_report

      brands = []
      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        brand_hash = validate_hash(Brand.column_names, clean_csv_hash)
        brand = Brand.new(brand_hash)
        brands << brand
      end
      Brand.import(brands)
      completion_msg(Brand, file_name)
    end



    def import_seed_uni_accounts(file_name)
      # CsvTool.new.import_seed_uni_accounts('3_indexers.csv')
      # CsvTool.new.import_seed_uni_accounts('4_locations.csv')
      # CsvTool.new.import_seed_uni_accounts('5_whos.csv')
      # CsvTool.new.import_seed_uni_accounts('6_core_accounts.csv')

      @file_path = "#{@seeds_dir_path}/#{file_name}"

      clean_csv_hashes = iterate_csv_w_error_report
      accounts = []

      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        account_hash = validate_hash(UniAccount.column_names, clean_csv_hash)
        account = UniAccount.new(account_hash)
        accounts << account
      end
      UniAccount.import(accounts)
      UniMigrator.new.uni_account_migrator
      completion_msg(UniAccount, file_name)
    end




    def import_seed_uni_contacts(file_name)
      # CsvTool.new.import_seed_uni_contacts('9_contacts.csv')

      binding.pry
      @file_path = "#{@seeds_dir_path}/#{file_name}"
      binding.pry

      clean_csv_hashes = iterate_csv_w_error_report
      contacts = []

      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        contact_hash = validate_hash(UniContact.column_names, clean_csv_hash)
        contact = UniContact.new(contact_hash)
        contacts << contact
      end
      UniContact.import(contacts)
      UniMigrator.new.uni_contact_migrator
      completion_msg(UniContact, file_name)
    end



    def import_seed_terms(file_name)
      # CsvTool.new.import_seed_terms('7_terms.csv') # indexer_terms

      binding.pry
      @file_path = "#{@seeds_dir_path}/#{file_name}"
      binding.pry

      clean_csv_hashes = iterate_csv_w_error_report
      terms = []

      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        term_hash = validate_hash(Term.column_names, clean_csv_hash)
        term = Term.new(term_hash)
        terms << term
      end
      Term.import(terms)
      completion_msg(Term, file_name)
    end



    def import_seed_webs(file_name)
      # CsvTool.new.import_seed_webs('1_clean_urls.csv')
      # CsvTool.new.import_seed_webs('2_redirects.csv')

      binding.pry
      @file_path = "#{@seeds_dir_path}/#{file_name}"
      binding.pry

      clean_csv_hashes = iterate_csv_w_error_report
      webs = []

      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        web_hash = validate_hash(Web.column_names, clean_csv_hash)

        url = web_hash['url']
        redirect_url = web_hash['url_redirect_id'] ## Grabs url in id column to replace with id number (below)
        redirect_url_obj = Web.find_by(url: redirect_url) if redirect_url
        web_hash['url_redirect_id'] = redirect_url_obj.id if (redirect_url && redirect_url_obj)
        url_obj = Web.find_by(url: url)

        if url_obj
          update_obj_if_changed(web_hash, url_obj)
        else
          url_obj = Web.new(web_hash)
          webs << url_obj
        end

      end
      Web.import(webs)
      completion_msg(Web, file_name)
    end


    def update_obj_if_changed(hash, obj)
      if hash['updated_at']
        hash.delete('updated_at')
      end
      updated_attributes = (hash.values) - (obj.attributes.values)
      obj.update_attributes(hash) if !updated_attributes.empty?
    end


    def validate_hash(cols, hash)
      # cols.map!(&:to_sym)
      keys = hash.keys
      keys.each { |key| hash.delete(key) if !cols.include?(key) }
      return hash
    end


    def iterate_csv_w_error_report
      puts "\n\nPreparing CSV for Import..."

      clean_csv_hashes = []
      counter = 0
      error_row_numbers = []
      @headers = []
      File.open(@file_path).each do |line|
        begin
          line = line&.gsub(/\s/, ' ')&.strip

          CSV.parse(line) do |row|
            counter > 0 ? clean_csv_hashes << row_to_hash(row) : @headers = row
            counter += 1
          end
        rescue => er
          error_row_numbers << {"#{counter}": "#{er.message}"}
          counter += 1
          next
        end
      end

      error_report(error_row_numbers)
      return clean_csv_hashes
    end


    def error_report(error_row_numbers)
      puts "\nCSV data ready to import.\nCSV Errors Found: #{error_row_numbers.length}\nRows containing errors (if any) will be skipped.\nErrors on the lines listed below (if any):"

      error_row_numbers.each_with_index { |hash, i| puts "#{i+1}) Row #{hash.keys[0]}: #{hash.values[0]}." }
    end

    def row_to_hash(row)
      h = Hash[@headers.zip(row)]
      h.symbolize_keys
    end


    def migration_report
      # DISPLAY FINAL RESULTS AFTER MIGRATION COMPLETES.
      puts "Accounts: #{Account.all.count}"
      puts "Contacts: #{Contact.all.count}"

      puts "Webs: #{Web.all.count}"
      puts "Webings: #{Webing.all.count}"

      puts "Phones: #{Phone.all.count}"
      puts "Phonings: #{Phoning.all.count}"

      puts "Addresses: #{Address.all.count}"
      puts "AccountAddresses: #{AccountAddress.all.count}"

      puts "Templates: #{Template.all.count}"
      puts "Who: #{Who.all.count}"

      puts "Job Titles: #{Title.all.count}"
      puts "Job Descriptions: #{Description.all.count}"

      puts "Whos: #{Who.all.count}"
      puts "Terms: #{Term.all.count}"
      puts "Brands: #{Brand.all.count}"
    end

  end


end
