# Notes:
# 1) CsvTool class calls CsvToolMod module.  Both files work together.
# 2) Note: Ensure config/application.rb extends autoload to concerns.

## Call: CsvTool.new(Account).backup_csv
## Call: CsvTool.new(Account).download_csv

## Call: CsvTool.new(Account).import_csv
## Call: CsvTool.new(Account).iterate_csv
###########################################

require 'pry'

class CsvToolParser
  extend ActiveSupport::Concern

  def initialize
    puts "\n\nInside CsvToolParser!\n\n"
    @account_hashes = []
  end

  ###### CONTACTS BELOW - NOT COMPLETD YET#######

# call: CsvToolParser.new.import_contacts
  def import_contacts
    account_hashes = CsvTool.new(Contact).iterate_csv
    # contact_hashes = CsvTool.new(Contact).iterate_csv_w_error_report
    contact_hashes.each { |hash| parse_contacts(hash) }
  end

  def parse_contacts(hash)
    ## Important: Web Contacts don't have act_num, so find_by(id of source:Web act with same url.)
    ## Keep Url in staffers to link to accounts, but don't save url to db.  just used to link.

    if hash[:source] == 'Web'
      # .....find account_id by url and act name, and act source = scraped.
    elsif hash[:source] == 'CRM'
      # .....find account_id by act_num (sfdc_id only) and act source = crm.
    elsif hash[:source] == 'Cop'
      # .....find account_id by act_num (sfdc_id only 'cop....') and act source = cop.
    else
      puts "Other option??"
    end

    # schema attr names below:
    # account_id
    # cont_num
    # source
    # status
    # full_name
    # first_name
    # last_name
    # email
    # job_title

    # contact_hash = {
    #   X: hash[:X],
    #   X: hash[:X],
    #   X: hash[:X],
    #   X: hash[:X],
    #   X: hash[:X],
    #   X: hash[:X],
    #   X: hash[:X],
    #   X: hash[:X],
    #   X: hash[:X],
    #   X: hash[:X],
    # }

    account_id = Account.find_by(act_num: hash[:act_num])
    contact_hash = {id: hash[:id]}.merge(contact_hash) if hash[:id].present?
    contact = Contact.find_or_create_by(contact_hash)
    contact.phones << Phone.find_or_create_by(phone: hash[:phone])
  end



  ###### CONTACTS ABOVE - NOT COMPLETD YET#######

# call: CsvToolParser.new.import_accounts
  def import_accounts
    # account_hashes = CsvTool.new(Account).iterate_csv
    account_hashes = CsvTool.new(Account).iterate_csv_w_error_report
    account_hashes.each { |hash| parse_accounts(hash) }
  end

  def parse_accounts(hash)
    ## Careful regarding 'archived urls' in indexers.  Must be skipped!
    account_hash = {
      act_num: hash[:act_num],
      source: hash[:source],
      act_name: hash[:act_name],
      status: hash[:status]}

    address_hash = {
      street: hash[:street],
      city: hash[:city],
      state: hash[:state],
      zip: hash[:zip],
      full: hash[:full],
      pin: hash[:pin]}

    account_hash = {id: hash[:id]}.merge(account_hash) if hash[:id].present?
    account = Account.find_or_create_by(account_hash)

    begin
      account.phones << Phone.find_or_create_by(phone: hash[:phone])
    rescue ActiveRecord::RecordInvalid => e
      puts e.message
    end

    # account.url = Url.find_or_create_by(url: hash[:raw_url])
    if hash[:clean_url].present?
      saved_clean_url = Url.find_by(url: hash[:clean_url]&.strip)
      saved_clean_url = Url.create(url: hash[:clean_url]&.strip, archive: false, status: 'valid') if !saved_clean_url.present?

      if hash[:raw_url].present?
        saved_raw_url = Url.find_by(url: hash[:raw_url]&.strip)
        saved_raw_url = Url.create(url: hash[:raw_url]&.strip, archive: true, status: 'archived', redirects_to: saved_clean_url.id) if !saved_raw_url.present?
        account.url = saved_raw_url
      end

    elsif !hash[:clean_url].present? && hash[:raw_url].present?
      saved_raw_url = Url.find_by(url: hash[:raw_url]&.strip)
      saved_raw_url = Url.create(url: hash[:raw_url]&.strip, archive: false, status: 'imported') if !saved_raw_url.present?
      account.url = saved_raw_url
    end

    account.address = Address.find_or_create_by(address_hash)

    ###### Active Record Nested Attributes ######
    # params = { account: { act_name: hash[:act_name], url_attributes: { url: hash[:url] } } }
    # account = Account.create(params[:account])
    # params = { member: { name: 'Jack', avatar_attributes: { icon: 'smiling' } } }
    # member = Member.create(params[:member])
    # Account.create(act_name: 'awesome', url_attributes: {url: 'www.awesome.com'})
    # Account.create(act_name: 'awesome', contact_attributes: {full_name: 'Tony Snow'})
    # cont = Contact.create(account_id: 1, full_name: 'sunny')
  end

  # call: CsvToolParser.new.import_urls
  def import_urls
    url_hashes = CsvTool.new(Url).iterate_csv_w_error_report
    url_hashes.each { |hash| parse_urls(hash) }
  end

  def parse_urls(hash)
    clean_url_hash = {archive: false,
                      status: 'valid',
                      url: hash[:clean_url]&.strip,
                      staff_page: hash[:staff_page]&.strip,
                      locations_page: hash[:locations_page]&.strip}

    if (hash[:archive] == 'FALSE' || !hash[:archive].present?) && hash[:clean_url].present?
      # binding.pry ## 1: Not Archived & Has Clean Url
      saved_clean_url = Url.find_or_create_by(url: hash[:clean_url]&.strip)
      saved_clean_url.update_attributes(clean_url_hash)

      saved_raw_url = Url.find_or_create_by(url: hash[:raw_url]&.strip)
      saved_raw_url.update_attributes(archive: true,
                            redirects_to: saved_clean_url.id,
                            status: 'archived')

    elsif hash[:archive] == 'TRUE' && hash[:clean_url].present?
      # binding.pry ## 2: Archived & Has Clean Url
      saved_clean_url = Url.find_by(url: hash[:clean_url]&.strip)
      saved_clean_url = Url.create(clean_url_hash) if !saved_clean_url.present?

      saved_raw_url = Url.find_or_create_by(url: hash[:raw_url]&.strip)
      saved_raw_url.update_attributes(archive: true,
                            redirects_to: saved_clean_url.id,
                            status: 'archived')

    elsif hash[:archive] == 'TRUE' && !hash[:clean_url].present?
      # binding.pry ## 3: Archived & No Clean Url (usually due to error or invalid url.)
      raw_url_already_saved = Url.find_by(url: hash[:raw_url]&.strip)
      if !raw_url_already_saved.present?
        saved_raw_url = Url.create(url: hash[:raw_url]&.strip, archive: true, status: hash[:status])
      end

    elsif (hash[:archive] == 'FALSE' || !hash[:archive].present?) && !hash[:clean_url].present?
      # binding.pry ## 4: Not Archived & No Clean Url (Might be newer url, which has not been 'redirected yet.')
      raw_url_already_saved = Url.find_by(url: hash[:raw_url]&.strip)
      if !raw_url_already_saved.present?
        saved_raw_url = Url.create(url: hash[:raw_url]&.strip, archive: false, status: hash[:status])
      end

    else
      puts "5th option?"
      binding.pry
    end

  end


end

# Notes:
#
# Add to Migrations:
#   Url
#     staff_link
#     location_link
#     status (valid/redirect)
#     redirect_id
