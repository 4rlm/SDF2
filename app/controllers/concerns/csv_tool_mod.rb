# Notes:
# 1) CsvTool class calls CsvToolMod module.  Both files work together.
# 2) Note: Ensure config/application.rb extends autoload to concerns.

## Call: CsvTool.new(Account).backup_csv
## Call: CsvTool.new(Account).download_csv

## Call: CsvTool.new(Account).import_csv
## Call: CsvTool.new(Account).iterate_csv
###########################################

require 'csv'
require 'pry'

module CsvToolMod
  extend ActiveSupport::Concern

  module Export
    def backup_csv
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

    def import_csv
      # CsvTool.new(Account).import_csv

      clean_csv_hashes = iterate_csv_w_error_report

      accounts = []
      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        account_hash = validate_hash(Account.column_names, clean_csv_hash)
        accounts << Account.new(account_hash)
      end

      binding.pry
      Account.import(accounts)
      binding.pry


      ### ABOVE - TRIAL OF ACTIVE RECORD IMPORT GEM ABOVE ###



      # clean_csv_hashes.each do |clean_csv_hash|
      #   clean_csv_hash = clean_csv_hash.stringify_keys
      #   clean_csv_array = (clean_csv_hash.to_a)
      #
      #   valid_hash = validate_hash(@model.column_names, clean_csv_hash)
      #   remaining_clean_csv_array = clean_csv_array - valid_hash.to_a
      #
      #   begin
      #     if @model = Account
      #       crm_acct_num = valid_hash['crm_acct_num']
      #       acct_id = valid_hash['id']
      #
      #       if acct_id.present?
      #         binding.pry
      #         account = Account.find_or_create_by(id: acct_id)
      #         account.update_attributes(valid_hash)
      #       elsif crm_acct_num.present?
      #         account = Account.find_or_create_by(crm_acct_num: crm_acct_num)
      #         account.update_attributes(valid_hash)
      #       else
      #         account = Account.create(valid_hash)
      #       end
      #
      #       web_hash = validate_hash(Web.column_names, remaining_clean_csv_array.to_h)
      #       address_hash = validate_hash(Address.column_names, remaining_clean_csv_array.to_h)
      #       phone_hash = validate_hash(Phone.column_names, remaining_clean_csv_array.to_h)
      #
      #       url = web_hash['url']
      #       phone = phone_hash['phone']
      #
      #       if url.present?
      #         web_obj = Web.find_or_create_by(url: url)
      #         web_obj.update_attributes(web_hash)
      #         account.webs << web_obj if !account.webs.include?(web_obj)
      #       end
      #
      #       if phone.present?
      #         phone_obj = Phone.find_or_create_by(phone: phone)
      #         phone_obj.update_attributes(phone_hash)
      #         account.phones << phone_obj if !account.phones.include?(phone_obj)
      #       end
      #
      #       address_obj = Address.find_or_create_by(address_hash)
      #       account.addresses << address_obj if !account.addresses.include?(address_obj)
      #
      #     elsif @model = Contact
      #       if obj = @model.find_by(crm_cont_num: valid_hash["crm_cont_num"]) || obj = @model.find_by(id: valid_hash["id"])
      #         obj.update_attributes(valid_hash)
      #       else
      #         @model.record_timestamps = true
      #         @model.create!(valid_hash)
      #       end
      #     end
      #
      #   rescue
      #     puts "\n\nDuplicate Data Error\n\n"
      #   end
      #
      # end ## end of CSV for each

    end


    def validate_hash(cols, hash)
      # cols.map!(&:to_sym)
      keys = hash.keys
      keys.each { |key| hash.delete(key) if !cols.include?(key) }
      return hash
    end


  ## Call: CsvTool.new(Account).iterate_csv_w_error_report
    def iterate_csv_w_error_report
      puts "\n\nImporting CSV.  This might take a few minutes ..."

      clean_csv_hashes = []
      counter = 0
      error_row_numbers = []
      @headers = []
      File.open(@file_path).each do |line|
        begin
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

    # call: CsvToolParser.new.import_urls
    def error_report(error_row_numbers)
      puts "\nCSV data successfully imported.\nBut #{error_row_numbers.length} rows were skipped due to the following errors on the lines listed below:\n\n"

      error_row_numbers.each_with_index { |hash, i| puts "#{i+1}) Row #{hash.keys[0]}: #{hash.values[0]}." }
    end

    def row_to_hash(row)
      h = Hash[@headers.zip(row)]
      h.symbolize_keys
    end






    # call: CsvToolParser.new.import_urls
    ## Call: CsvTool.new(Account).iterate_csv
    def iterate_csv
      puts "\n\nImporting CSV.  This might take a few minutes ..."
      binding.pry
      @csv_hashes = []
      # CSV.foreach(@file_path, headers: true, skip_blanks: true) do |row|
      # CSV.foreach(@file_path, encoding: "UTF-32BE:UTF-8", headers: true, skip_blanks: true) do |row|
      CSV.foreach(@file_path, encoding: 'windows-1252:utf-8', headers: true, skip_blanks: true) do |row|
        @csv_hashes << row.to_hash.symbolize_keys
      end

      @csv_hashes
    end





    ###### ORIGINAL BELOW ########
    # def import_csv
    #   upload_csv
    #   @csv_hashes.each do |valid_hash|
    #     begin
    #       if obj = @model.find_by(id: valid_hash["id"])
    #         @model.record_timestamps = false
    #         obj.update_attributes(valid_hash)
    #       else
    #         @model.record_timestamps = true
    #         @model.create!(valid_hash)
    #       end
    #     rescue
    #       puts "\n\nDuplicate Data Error\n\n"
    #     end
    #
    #   end
    # end
    #
    # def iterate_csv
    #   upload_csv
    #   return @csv_hashes
    # end
    #
    #
    # def upload_csv
    #   @csv_hashes = []
    #
    #   CSV.foreach(@file_path, headers: true, skip_blanks: true) do |row|
    #     valid_hash = validate_hash(@model.column_names, row.to_hash)
    #     @csv_hashes << valid_hash
    #   end
    #
    #   @csv_hashes
    # end

######################

  end

end
