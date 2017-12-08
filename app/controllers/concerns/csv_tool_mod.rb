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

    def import_uni_accounts
      # CsvTool.new(Account).import_uni_accounts
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


    def import_uni_contacts
      # CsvTool.new(Contact).import_uni_contacts
      clean_csv_hashes = iterate_csv_w_error_report
      contacts = []

      clean_csv_hashes.each do |clean_csv_hash|
        clean_csv_hash = clean_csv_hash.stringify_keys
        contact_hash = validate_hash(UniContact.column_names, clean_csv_hash)
        contact = UniContact.new(contact_hash)
        contacts << contact
      end
      UniContact.import(contacts)
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




    ### Migrates uni_account table (csv imported accounts) to their proper join tables, then deletes itself.
    def uni_account_migrator
      # CsvTool.new(Account).import_uni_accounts
      # CsvTool.new(Account).uni_account_migrator

      # UniAccount.all.each do |uni_account|
      # UniAccount.find((1..603).to_a).each do |uni_account|
      UniAccount.in_batches.each do |each_batch|
        each_batch.each do |uni_account|

          begin
            # FORMAT INCOMING DATA ROW FROM UniAccount.
            uni_account_hash = uni_account.attributes
            uni_account_hash.delete('id')
            uni_account_hash['id'] = uni_account_hash.delete('account_id')
            uni_account_hash.delete_if { |key, value| value.blank? }

            # CREATE ACCOUNT HASH, AND ARRAY OF NON-ACCOUNT DATA FROM ROW.
            uni_account_array = (uni_account_hash.to_a)
            account_hash = validate_hash(Account.column_names, uni_account_array.to_h)
            non_account_attributes_array = uni_account_array - account_hash.to_a

            # FIND OR CREATE ACCOUNT, THEN UPDATE IF APPLICABLE
            crm_acct_num = account_hash['crm_acct_num']
            acct_id = account_hash['id']
            account = Account.find(acct_id) if acct_id
            account = Account.find_by(crm_acct_num: crm_acct_num) if (!account && crm_acct_num)
            account ? update_obj_if_changed(account_hash, account) : account = Account.create(account_hash)

            # FIND OR CREATE URL, THEN UPDATE IF APPLICABLE
            url = uni_account_hash['url']
            web_hash = validate_hash(Web.column_names, non_account_attributes_array.to_h) if url.present?
            save_complex_association('web', account, {'url' => url}, web_hash) if url.present?

            # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
            phone = uni_account_hash['phone']
            save_simple_association('phone', account, obj_hash={'phone' => phone}) if phone.present?

            # FIND OR CREATE ADDRESS, THEN UPDATE IF APPLICABLE
            address_hash = validate_hash(Address.column_names, non_account_attributes_array.to_h)
            address_concat = address_hash.values.compact.join(',')
            if address_concat
              full_address = address_hash.except('address_pin').values.compact.join(', ')
              address_hash['full_address'] = full_address
              save_complex_association('address', account, {'full_address' => full_address}, address_hash)
            end

          rescue
            puts "\n\nRESCUE ERROR!!\n\n"
            binding.pry
          end
        end ## end of iteration.
      end

      # DISPLAY FINAL RESULTS AFTER MIGRATION COMPLETES.
      puts "Accounts: #{Account.all.count}"
      puts "Webs: #{Web.all.count}"
      puts "Webings: #{Webing.all.count}"
      puts "Phones: #{Phone.all.count}"
      puts "Phonings: #{Phoning.all.count}"
      puts "Addresses: #{Address.all.count}"
      puts "AccountAddresses: #{AccountAddress.all.count}"
    end

    ### Migrates uni_contact table (csv imported contacts) to their proper join tables, then deletes itself.
    def uni_contact_migrator
      # CsvTool.new(Contact).import_uni_contacts
      # CsvTool.new(Contact).uni_contact_migrator

      # UniContact.all.each do |uni_contact|
      # UniContact.find((1..100).to_a).each do |uni_contact|
      UniContact.in_batches.each do |each_batch|
        each_batch.each do |uni_contact|

          begin
            # FORMAT INCOMING DATA ROW FROM UniContact.
            uni_contact_hash = uni_contact.attributes
            uni_contact_hash.delete('id')
            uni_contact_hash['id'] = uni_contact_hash.delete('contact_id')
            uni_contact_hash.delete_if { |key, value| value.blank? }

            # CREATE CONTACT HASH, AND ARRAY OF NON-CONTACT DATA FROM ROW.
            uni_contact_array = uni_contact_hash.to_a
            contact_hash = validate_hash(Contact.column_names, uni_contact_array.to_h)
            non_contact_attributes_array = uni_contact_array - contact_hash.to_a
            url = uni_contact_hash['url'] ## Needed up here, because used to find Account ID

            # FIND OR CREATE ACCOUNT, THEN UPDATE IF APPLICABLE
            # Need to identify account before contact, to save account id in contact - less DB hits.
            account_id = uni_contact_hash['account_id']
            account_hash = validate_hash(Account.column_names, non_contact_attributes_array.to_h)
            crm_acct_num = uni_contact_hash['crm_acct_num']
            account = Account.find(account_id) if account_id
            account = Account.find_by(crm_acct_num: crm_acct_num) if (!account && crm_acct_num)

            if (!account && url)
              web_object = Web.find_by(url: url)
              account = web_object.accounts.first if web_object
            end
            account ? update_obj_if_changed(account_hash, account) : account = Account.create(account_hash)

            # FIND OR CREATE CONTACT, THEN UPDATE IF APPLICABLE
            contact_hash['account_id'] = account.id if !contact_hash['account_id']
            cont_id = contact_hash['id']
            crm_cont_num = uni_contact_hash['crm_cont_num']
            email = uni_contact_hash['email']
            contact = Contact.find(cont_id) if cont_id
            contact = Contact.find_by(crm_cont_num: crm_cont_num) if (!contact && crm_cont_num)
            contact = Contact.find_by(email: email) if (!contact && email)
            contact.present? ? update_obj_if_changed(contact_hash, contact) : contact = Contact.create(contact_hash)

            # FIND OR CREATE WEB, THEN UPDATE IF APPLICABLE
            web_hash = validate_hash(Web.column_names, non_contact_attributes_array.to_h) if url.present?
            save_complex_association('web', contact, {'url' => url}, web_hash) if url.present?

            # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
            phone = uni_contact_hash['phone']
            save_simple_association('phone', contact, {'phone' => phone}) if phone.present?

            # FIND OR CREATE TITLE, THEN UPDATE IF APPLICABLE
            job_title = uni_contact_hash['job_title']
            save_simple_association('title', contact, {'job_title' => job_title}) if job_title.present?

            # FIND OR CREATE DESCRIPTION, THEN UPDATE IF APPLICABLE
            job_description = uni_contact_hash['job_description']
            save_simple_association('description', contact, {'job_description' => job_description}) if job_description.present?

          rescue
            puts "\n\nRESCUE ERROR!!\n\n"
            binding.pry
          end
        end ## end of iteration.
      end

      # DISPLAY FINAL RESULTS AFTER MIGRATION COMPLETES.
      puts "Contacts: #{Contact.all.count}"
      puts "Accounts: #{Account.all.count}"
      puts "Webs: #{Web.all.count}"
      puts "Webings: #{Webing.all.count}"
      puts "Phones: #{Phone.all.count}"
      puts "Phonings: #{Phoning.all.count}"
      puts "Job Titles: #{Title.all.count}"
      puts "Job Descriptions: #{Description.all.count}"
    end


    def save_simple_association(model, parent, attr_hash)
      obj = model.classify.constantize.find_or_create_by(attr_hash)
      parent.send(model.pluralize.to_sym) << obj if (obj && !parent.send(model.pluralize.to_sym).include?(obj))

      # if phone.present?
      #   phone_obj = Phone.find_or_create_by(phone: phone)
      #   account.phones << phone_obj if !account.phones.include?(phone_obj)
      # end
    end


    def save_complex_association(model, parent, attr_hash, obj_hash)
      obj = model.classify.constantize.find_by(attr_hash)
      obj.present? ? update_obj_if_changed(obj_hash, obj) : obj = model.classify.constantize.create(obj_hash)
      parent.send(model.pluralize.to_sym) << obj if (obj && !parent.send(model.pluralize.to_sym).include?(obj))

      # if url.present?
      #   web_obj = Web.find_by(url: url)
      #   web_obj.present? ? update_obj_if_changed(web_hash, web_obj) : web_obj = Web.create(web_hash)
      #   contact.webs << web_obj if !contact.webs.include?(web_obj)
      # end
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


  end




end
