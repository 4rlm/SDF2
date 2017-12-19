# require 'open-uri'
# require 'mechanize'
# require 'uri'
# require 'nokogiri'
# require 'socket'
# require 'httparty'
# require 'delayed_job'
# require 'curb' #=> for url_redirector
require 'web_formatter'


## CLASS METHOD TO START, EXPLAIN, OR TEST OTHER FORMATTER CLASSES AND METHODS.
class AboutFormatter
  include WebFormatter

  # AboutFormatter.new
  # AboutFormatter.new.method_name

  def initialize
    puts "Welcome to formatter!"
    ## could auto-run methods or mudules if desired.
    # AddressFormatter.welcome
  end

  def run_all_formatters
  # Call: AboutFormatter.new.run_all_formatters
    puts "Runs all Formatters methods:\nformat_webs\nformat_addresses\nformat_phones"

    format_webs
    format_addresses
    format_phones
  end

  def format_webs
    # Call: AboutFormatter.new.format_webs

    # web_ids = Web.all.order("updated_at ASC").pluck(:id)
    # web_ids = Web.where.not(staff_page: nil).order("updated_at ASC").pluck(:id)
    web_ids = Web.all.order("updated_at ASC").pluck(:id)

    web_ids.each do |id|
      web_obj = Web.find(id)
      migrate_web_and_links(web_obj) # via WebFormatter
    end

  end

  def format_addresses
    # AboutFormatter.new.format_addresses
    # Address.where.not(full_address: nil).in_batches.each do |each_batch|
    # Address.in_batches.each do |each_batch|
    address_ids = Address.all.order("updated_at ASC").pluck(:id)
    address_ids.each do |id|
      address_obj = Address.find(id)
      current_zip = address_obj.zip
      new_zip = AddressFormatter.format_zip(current_zip)
      address_obj.update_attributes(zip: new_zip) if current_zip != new_zip

      update_hash = {}
      current_full_address = address_obj.full_address
      current_address_pin = address_obj.address_pin

      new_full_address = AddressFormatter.generate_full_address(address_obj)
      update_hash[:full_address] = new_full_address if current_full_address != new_full_address
      new_address_pin = AddressFormatter.generate_address_pin(address_obj.street, address_obj.zip)
      update_hash[:address_pin] = new_address_pin if current_address_pin != new_address_pin
      !update_hash.empty? ? address_obj.update_attributes(update_hash) : address_obj.touch
    end
  end

  def format_phones
    # Call: AboutFormatter.new.format_phones
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
