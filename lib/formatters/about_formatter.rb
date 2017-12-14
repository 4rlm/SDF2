# require 'open-uri'
# require 'mechanize'
# require 'uri'
# require 'nokogiri'
# require 'socket'
# require 'httparty'
# require 'delayed_job'
# require 'curb' #=> for url_redirector

## CLASS METHOD TO START, EXPLAIN, OR TEST OTHER FORMATTER CLASSES AND METHODS.
class AboutFormatter
  # AboutFormatter.new
  # AboutFormatter.new.method_name

  def initialize
    puts "Welcome to formatter!"
    AddressFormatter.welcome
  end

  def format_addresses
    # AboutFormatter.new.format_addresses
    # Address.where.not(full_address: nil).in_batches.each do |each_batch|
    Address.in_batches.each do |each_batch|
      each_batch.each do |obj|
        current_zip = obj.zip
        new_zip = AddressFormatter.format_zip(current_zip)
        obj.update_attributes(zip: new_zip) if current_zip != new_zip

        update_hash = {}
        current_full_address = obj.full_address
        current_address_pin = obj.address_pin

        new_full_address = AddressFormatter.generate_full_address(obj)
        update_hash[:full_address] = new_full_address if current_full_address != new_full_address

        new_address_pin = AddressFormatter.generate_address_pin(obj.street, obj.zip)
        update_hash[:address_pin] = new_address_pin if current_address_pin != new_address_pin

        obj.update_attributes(update_hash) if !update_hash.empty?
      end
    end
  end

  def format_phones
    # AboutFormatter.new.format_phones
    # account = Account.find(25149)

    # phone_objects = Phone.where.not(phone: nil)
    phone_objects = Phone.all

    phone_objects.each do |phone_obj|
      phone = phone_obj.phone
      if phone
        valid_phone = PhoneFormatter.validate_phone(phone)

        if valid_phone.nil?
          binding.pry
          phone_obj.destroy
          binding.pry
        elsif valid_phone != phone
          binding.pry
          phone_obj.update_attributes(phone: valid_phone)
          binding.pry
        end

      end
    end
  end



end
