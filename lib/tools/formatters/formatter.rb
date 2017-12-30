# require 'open-uri'
# require 'mechanize'
# require 'uri'
# require 'nokogiri'
# require 'socket'
# require 'httparty'
# require 'delayed_job'
# require 'curb' #=> for url_redirector

# %w{open-uri mechanize uri nokogiri socket httparty delayed_job curb}.each { |x| require x }
require 'web_formatter'


## CLASS METHOD TO START, EXPLAIN, OR TEST OTHER FORMATTER CLASSES AND METHODS.
class Formatter
  include WebFormatter

  # Formatter.new
  # Formatter.new.method_name

  def initialize
    puts "Welcome to formatter!"
    ## could auto-run methods or mudules if desired.
    # AdrFormatter.welcome
  end

  def run_all_formatters
  # Call: Formatter.new.run_all_formatters
    puts "Runs all Formatters methods:\nformat_webs\nformat_adrs\nformat_phones"

    format_webs
    format_adrs
    format_phones
  end

  def format_webs
    # Call: Formatter.new.format_webs

    # web_ids = Web.all.order("updated_at ASC").pluck(:id)
    # web_ids = Web.where.not(staff_page: nil).order("updated_at ASC").pluck(:id)
    web_ids = Web.all.order("updated_at ASC").pluck(:id)

    web_ids.each do |id|
      web_obj = Web.find(id)
      migrate_web_and_links(web_obj) # via WebFormatter
    end

  end

  def format_adrs
    # Formatter.new.format_adrs
    # Adr.where.not(full_adr: nil).in_batches.each do |each_batch|
    # Adr.in_batches.each do |each_batch|
    adr_ids = Adr.all.order("updated_at ASC").pluck(:id)
    adr_ids.each do |id|
      adr_obj = Adr.find(id)
      current_zip = adr_obj.zip
      new_zip = AdrFormatter.format_zip(current_zip)
      adr_obj.update_attributes(zip: new_zip) if current_zip != new_zip

      update_hash = {}
      current_full_adr = adr_obj.full_adr
      current_adr_pin = adr_obj.adr_pin

      new_full_adr = AdrFormatter.generate_full_adr(adr_obj)
      update_hash[:full_adr] = new_full_adr if current_full_adr != new_full_adr
      new_adr_pin = AdrFormatter.generate_adr_pin(adr_obj.street, adr_obj.zip)
      update_hash[:adr_pin] = new_adr_pin if current_adr_pin != new_adr_pin
      !update_hash.empty? ? adr_obj.update_attributes(update_hash) : adr_obj.touch
    end
  end

  def format_phones
    # Call: Formatter.new.format_phones
    phone_ids = Phone.where.not(phone: nil).order("updated_at ASC").pluck(:id)
    phone_ids.each do |id|
      phone_obj = Phone.find(id)
      phone = phone_obj.phone

      if phone
        valid_phone = PhoneFormatter.validate_phone(phone)

        if valid_phone.nil?
          phone_obj.destroy
        elsif valid_phone && valid_phone != phone
          phone_obj.update_attributes(phone: valid_phone)
        else
          phone_obj.touch
        end

      end
    end
  end



end
