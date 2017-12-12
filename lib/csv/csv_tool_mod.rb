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
        file_name = "BU_#{table_name.pluralize}"
        CsvTool.new(model, file_name).backup_csv
        #Ex. CsvTool.new(Term, 'terms').backup_csv
      end

    end


    def backup_csv
      # CsvTool.new(Term, 'terms').backup_csv
      CSV.open(@file_path, "wb") do |csv|
        csv << @model.attribute_names
        @model.all.each { |r| csv << r.attributes.values }
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

      terms_csv = '7_terms' # indexer_terms
      brands_csv = '8_brands' # in_host_pos
      clean_urls_csv = '1_clean_urls'
      redirects_csv = '2_redirects'
      indexers_csv = '3_indexers'
      locations_csv = '4_locations'
      whos_csv = '5_whos'
      core_accounts_csv = '6_core_accounts'
      contacts_csv = '9_contacts'

      CsvTool.new(Term, terms_csv).import_terms
      completion_msg(Term, terms_csv)

      CsvTool.new(Brand, brands_csv).import_brands
      completion_msg(Brand, brands_csv)

      CsvTool.new(Web, clean_urls_csv).import_webs
      completion_msg(Web, clean_urls_csv)

      CsvTool.new(Web, redirects_csv).import_webs
      completion_msg(Web, redirects_csv)

      CsvTool.new(Account, indexers_csv).import_uni_accounts
      completion_msg(Account, indexers_csv)

      CsvTool.new(Account, locations_csv).import_uni_accounts
      completion_msg(Account, locations_csv)

      CsvTool.new(Account, whos_csv).import_uni_accounts
      completion_msg(Account, whos_csv)

      CsvTool.new(Account, core_accounts_csv).import_uni_accounts
      completion_msg(Account, core_accounts_csv)

      CsvTool.new(Contact, contacts_csv).import_uni_contacts
      completion_msg(Contact, contacts_csv)

    end

    def self.completion_msg(model, file_name)
      puts "\n\n== Imported #{file_name} to #{model} table. ==\n\n"
      migration_report
      binding.pry
    end

    def import_uni_accounts
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
    end

    def import_uni_contacts
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
    end


    def import_terms
      clean_csv_hashes = iterate_csv_w_error_report
      terms = []

      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        term_hash = validate_hash(Term.column_names, clean_csv_hash)
        term = Term.new(term_hash)
        terms << term
      end
      Term.import(terms)
    end


    def import_brands
      clean_csv_hashes = iterate_csv_w_error_report
      brands = []

      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        brand_hash = validate_hash(Brand.column_names, clean_csv_hash)
        brand = Brand.new(brand_hash)
        brands << brand
      end
      Brand.import(brands)
    end


    def import_webs
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


    def self.migration_report
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
