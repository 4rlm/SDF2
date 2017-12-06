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


    ### ORIGNAL IMPORT_CSV BELOW ###

    # def import_csv
    #   # CsvTool.new(Account).import_csv
    #
    #   CSV.foreach(@file_path, encoding: 'windows-1252:utf-8', headers: true, skip_blanks: true) do |row|
    #     valid_hash = validate_hash(@model.column_names, row.to_h)
    #     row_array = (row.to_a) - (valid_hash.to_a)
    #
    #     begin
    #       if @model = Account
    #         # if account = @model.find_by(crm_acct_num: valid_hash["crm_acct_num"]) || account = @model.find_by(id: valid_hash["id"])
    #         #   account.update_attributes(valid_hash)
    #         # else
    #         #   account = @model.record_timestamps = true
    #         #   account = @model.create!(valid_hash)
    #         # end
    #
    #         if valid_hash["crm_acct_num"].present?
    #           account = Account.find_or_create_by(crm_acct_num: valid_hash["crm_acct_num"])
    #           account.update_attributes(valid_hash)
    #         elsif valid_hash["id"].present?
    #           account = Account.find_or_create_by(id: valid_hash["id"])
    #           account.update_attributes(valid_hash)
    #         else
    #           account = Account.create(valid_hash)
    #         end
    #
    #         web_hash = validate_hash(Web.column_names, row_array.to_h)
    #         address_hash = validate_hash(Address.column_names, row_array.to_h)
    #         phone_hash = validate_hash(Phone.column_names, row_array.to_h)
    #
    #         url = web_hash['url']
    #         phone = phone_hash['phone']
    #
    #         if url.present?
    #           web_obj = Web.find_or_create_by(url: url)
    #           web_obj.update_attributes(web_hash)
    #           account.webs << web_obj if !account.webs.include?(web_obj)
    #         end
    #
    #         if phone.present?
    #           phone_obj = Phone.find_or_create_by(phone: phone)
    #           phone_obj.update_attributes(phone_hash)
    #           account.phones << phone_obj if !account.phones.include?(phone_obj)
    #         end
    #
    #         address_obj = Address.find_or_create_by(address_hash)
    #         account.addresses << address_obj if !account.addresses.include?(address_obj)
    #
    #       elsif @model = Contact
    #         if obj = @model.find_by(crm_cont_num: valid_hash["crm_cont_num"]) || obj = @model.find_by(id: valid_hash["id"])
    #           obj.update_attributes(valid_hash)
    #         else
    #           @model.record_timestamps = true
    #           @model.create!(valid_hash)
    #         end
    #         # grab account num, account_id, phone, url, etc.
    #       end
    #
    #     # begin
    #     #   if obj = @model.find_by(id: valid_hash["id"])
    #     #     @model.record_timestamps = false
    #     #     obj.update_attributes(valid_hash)
    #     #   else
    #     #     @model.record_timestamps = true
    #     #     @model.create!(valid_hash)
    #     #   end
    #
    #     rescue
    #       puts "\n\nDuplicate Data Error\n\n"
    #     end
    #
    #   end
    # end

    ### ORIGNAL IMPORT_CSV ABOVE ###


    #########################################

    # CsvTool.new(Account).uni_account_migrator
  def uni_account_migrator
    ### Migrates uni_account table (csv imported accounts) to their proper join tables, then deletes itself.

    UniAccount.all.each do |uni_account|

      uni_account_hash = uni_account.attributes
      uni_account_hash.delete('id')
      uni_account_hash['id'] = uni_account_hash.delete('account_id')
      uni_account_hash.delete_if { |key, value| value.blank? }
      uni_account_array = (uni_account_hash.to_a)

      account_hash = validate_hash(Account.column_names, uni_account_hash)
      non_account_attributes_array = uni_account_array - account_hash.to_a

      begin
        crm_acct_num = account_hash['crm_acct_num']
        acct_id = account_hash['id']

        if acct_id.present?
          account = Account.find(acct_id)
        elsif crm_acct_num.present?
          account = Account.find_by(crm_acct_num: crm_acct_num)
        end

        # account.present? ? update_obj_if_changed(account_hash, account) : account = Account.new(account_hash)
        account.present? ? update_obj_if_changed(account_hash, account) : account = Account.create(account_hash)

        # @accounts << account
        # account.save

        web_hash = validate_hash(Web.column_names, non_account_attributes_array.to_h)
        phone_hash = validate_hash(Phone.column_names, non_account_attributes_array.to_h)
        address_hash = validate_hash(Address.column_names, non_account_attributes_array.to_h)

        ## Below is a dummy data for testing.  be sure to remove later.
        # web_hash = {'url' => 'www.testing14.com'}
        # phone_hash = {'phone' => '555-123-0514'}

        url = web_hash['url']
        phone = phone_hash['phone']
        address_concat = address_hash.values.compact.join(',')


        if url.present?
          web_obj = Web.find_by(url: url)
          # if web_obj.present?
          #   update_obj_if_changed(web_hash, web_obj)
          #   account.webs << web_obj if !account.webs.include?(web_obj)
          # else
          #   account.webs.build(web_hash)
          # end

          if web_obj.present?
            update_obj_if_changed(web_hash, web_obj)
          else
            # account.webs.build(web_hash)
            web_obj = Web.create(web_hash)
          end
          account.webs << web_obj if !account.webs.include?(web_obj)
        end


        if phone.present?
          phone_obj = Phone.find_by(phone: phone)
          # if phone_obj.present?
          #   update_obj_if_changed(phone_hash, phone_obj)
          #   account.phones << phone_obj if !account.phones.include?(phone_obj)
          # else
          #   account.phones.build(phone_hash)
          # end

          if phone_obj.present?
            update_obj_if_changed(phone_hash, phone_obj)
          else
            # account.phones.build(phone_hash)
            phone_obj = Phone.create(phone_hash)
          end
          account.phones << phone_obj if !account.phones.include?(phone_obj)
        end


        if address_concat.present?
          full_address = address_hash.except('address_pin').values.compact.join(', ')
          address_obj = Address.find_by(full_address: full_address)
          address_hash['full_address'] = full_address

          # if address_obj.present?
          #   update_obj_if_changed(address_hash, address_obj)
          #   account.addresses << address_obj if !account.addresses.include?(address_obj)
          # else
          #   account.addresses.build(address_hash)
          # end

          if address_obj.present?
            update_obj_if_changed(address_hash, address_obj)
          else
            # account.addresses.build(address_hash)
            address_obj = Address.create(address_hash)
          end

          account.addresses << address_obj if !account.addresses.include?(address_obj)

        end

        # binding.pry

        # if account.changed? || account.webs.map(&:changed?) || account.phones.map(&:changed?) || account.addresses.map(&:changed?)
        #   binding.pry
        #   account.save
        # else
        #   binding.pry
        # end

        # @accounts.each(&:save)
        # binding.pry
        # @accounts << account

      rescue
        puts "\n\nDuplicate Data Error\n\n"
      end

    end ## end of CSV for each

    # @accounts.each(&:save)

    puts "Accounts: #{Account.all.count}"
    puts "Webs: #{Web.all.count}"
    puts "Phones: #{Phone.all.count}"
    puts "Addresses: #{Address.all.count}"

    puts "AccountWebs: #{AccountWeb.all.count}"
    puts "AccountAddresses: #{AccountAddress.all.count}"
    puts "Phonings: #{Phoning.all.count}"

    # ActiveRecord::Base.transaction { @accounts.each(&:save) }

  # end ## end of transaction

    # binding.pry
    # ActiveRecord::Base.transaction { @accounts.each(&:save) }
  end


  def update_obj_if_changed(hash, obj)
    updated_attributes = (hash.values) - (obj.attributes.values)
    obj.update_attributes(hash) if !updated_attributes.empty?
  end


    ### TESTING IMPORT_CSV BELOW ###

    def import_star_accounts
      # CsvTool.new(Account).import_star_accounts
      clean_csv_hashes = iterate_csv_w_error_report
      accounts = []

      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        account_hash = validate_hash(UniAccount.column_names, clean_csv_hash)
        account = UniAccount.new(account_hash)
        accounts << account
      end

      UniAccount.import(accounts)

    end

    ### TESTING IMPORT ABOVE

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
      CSV.foreach(@file_path, encoding: 'windows-1252:utf-8', headers: true, skip_blanks: true) do |row|
        @csv_hashes << row.to_hash.symbolize_keys
      end

      @csv_hashes
    end

  end

end
