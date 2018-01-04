# require 'open-uri'
# require 'mechanize'
# require 'uri'
# require 'nokogiri'
# require 'socket'
# require 'httparty'
# require 'delayed_job'
# require 'curb' #=> for curler

# %w{open-uri mechanize uri nokogiri socket httparty delayed_job curb}.each { |x| require x }
require 'web_formatter'
require 'phone_formatter'
require 'adr_formatter'
require 'act_formatter'


## CLASS METHOD TO START, EXPLAIN, OR TEST OTHER FORMATTER CLASSES AND METHODS.
class Formatter
  include WebFormatter
  include PhoneFormatter
  include AdrFormatter
  include ActFormatter


  #Call: Formatter.new.run_all_formatters
  def run_all_formatters
    puts "Runs all Formatters methods:\nformat_webs\nformat_adrs\nformat_phones"
    format_webs
    format_adrs
    format_phones
  end


  #Call: Formatter.new.format_webs
  def format_webs
    # web_ids = Web.all.order("updated_at ASC").pluck(:id)
    # web_ids = Web.where.not(staff_page: nil).order("updated_at ASC").pluck(:id)
    web_ids = Web.all.order("updated_at ASC").pluck(:id)

    web_ids.each do |id|
      web_obj = Web.find(id)
      migrate_web_and_links(web_obj) # via WebFormatter
    end

  end


  #CALL: Formatter.new.format_adrs
  def format_adrs
    # Adr.where.not(full_adr: nil).in_batches.each do |each_batch|
    # Adr.in_batches.each do |each_batch|
    adr_ids = Adr.all.order("updated_at ASC").pluck(:id)
    adr_ids.each do |id|
      adr_obj = Adr.find(id)
      current_zip = adr_obj.zip
      new_zip = AdrFormatter.format_zip(current_zip)
      adr_obj.update_attributes(zip: new_zip) if current_zip != new_zip

      update_hsh = {}
      current_full_adr = adr_obj.full_adr
      current_adr_pin = adr_obj.adr_pin

      new_full_adr = AdrFormatter.generate_full_adr(adr_obj)
      update_hsh[:full_adr] = new_full_adr if current_full_adr != new_full_adr
      new_adr_pin = AdrFormatter.generate_adr_pin(adr_obj.street, adr_obj.zip)
      update_hsh[:adr_pin] = new_adr_pin if current_adr_pin != new_adr_pin
      !update_hsh.empty? ? adr_obj.update_attributes(update_hsh) : adr_obj.touch
    end
  end


  #Call: Formatter.new.format_phones
  def format_phones
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








  #Call: Migrator.new.migrate_uni_acts

  #CALL: Formatter.new.letter_case_check(street)
  def letter_case_check(str)
    if str.present?
      flashes = str&.gsub(/[^ A-Za-z]/, '')&.strip&.split(' ')
      flash = flashes&.reject {|e| e.length < 3 }.join(' ')

      if flash.present?
        has_caps = flash.scan(/[A-Z]/).any?
        has_lows = flash.scan(/[a-z]/).any?
        if !has_caps || !has_lows
          str = str.split(' ')&.each { |el| el.capitalize! if el.gsub(/[^ A-Za-z]/, '')&.strip&.length > 2 }&.join(' ')
        end
      end
      return str
    end
  end


  #CALL: Formatter.new.check_conjunctions(str)
  def check_conjunctions(str)
    if str.present?
      commons = %w(a an and as by in Inc LLC of out to with)
      str_parts = str.split(' ')
      str_parts.map do |str_part|
        if str_part.scan(/[a-zA-Z]/).any?
          commons.each do |common|
            if str_part.downcase == common
              str_parts = str_parts&.join(' ')&.gsub(str_part, common)&.split(' ')
            end
          end
        end
      end
      str = str_parts.join(' ')
      return str
    end
  end



end
