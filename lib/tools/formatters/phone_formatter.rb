# require 'open-uri'
# require 'mechanize'
# require 'uri'
# require 'nokogiri'
# require 'socket'
# require 'httparty'
# require 'delayed_job'
# require 'curb' #=> for url_redirector


module PhoneFormatter
  # Call: PhoneFormatter.method_name

  def self.welcome
  # Call: PhoneFormatter.welcome
    puts "Welcome to PhoneFormatter!"
  end

  #################################
  ## Checks every phone number in table to verify that it meets phone criteria, then calls format_phone method to format valid results.  Otherwise destroys invalid phone fields and associations.

  # Call: PhoneFormatter.validate_phone(phone)
  def self.validate_phone(phone)
    if phone.present?
      reg = Regexp.new("[(]?[0-9]{3}[ ]?[)-.]?[ ]?[0-9]{3}[ ]?[-. ][ ]?[0-9]{4}")
      phone.first == "0" || phone.include?("(0") || !reg.match(phone) ? phone = nil : valid_phone = format_phone(phone)
      return valid_phone
    end
  end


  #################################
  ## FORMATS PHONE AS: (000) 000-0000
  ## Assumes phone is legitimate, then formats.  Not designed to detect valid phone number.

  # Call: PhoneFormatter.format_phone(phone)
  def self.format_phone(phone)
    regex = Regexp.new("[A-Z]+[a-z]+")
    if !phone.blank? && (phone != "N/A" || phone != "0") && !regex.match(phone)
      phone_stripped = phone.gsub(/[^0-9]/, "")
      (phone_stripped && phone_stripped[0] == "1") ? phone_step2 = phone_stripped[1..-1] : phone_step2 = phone_stripped

      final_phone = !(phone_step2 && phone_step2.length < 10) ? "(#{phone_step2[0..2]}) #{(phone_step2[3..5])}-#{(phone_step2[6..9])}" : phone
    else
      final_phone = nil
    end
    return final_phone
  end

    #################################


  # def phones_arr_cleaner
  #   puts "#{"="*30}\n\nIndexer: phones_arr_cleaner\n\n"
  #   indexers = Indexer.where.not("phones = '{}'")
  #
  #   indexers.each do |indexer|
  #     old_phones = indexer.phones
  #     new_phones = clean_phones_arr(old_phones)
  #
  #     if old_phones != new_phones
  #       puts "#{"-"*30}\nOLD Phones: #{old_phones}"
  #       puts "NEW Phones: #{new_phones}"
  #       indexer.update_attribute(:phones, new_phones)
  #     end
  #   end
  # end

  #################################
  # def clean_phones_arr(phones)
  #   return phones if phones.empty?
  #   new_phones = phones.map {|phone| phone_formatter(phone)} #=> via PhoneFormatter
  #   new_phones.delete_if {|x| x.blank?}
  #   new_phones.uniq.sort
  # end






  #####################


  # def remove_invalid_phones
  #   indexers = Indexer.where(archive: false)
  #   num = 0
  #   indexers.each do |indexer|
  #     phones = indexer.phones
  #     if phones.any?
  #       num += 1
  #       invalid = Regexp.new("[0-9]{5,}")
  #       valid_phones = phones.reject { |x| invalid.match(x) }
  #
  #       reg = Regexp.new("[(]?[0-9]{3}[ ]?[)-.]?[ ]?[0-9]{3}[ ]?[-. ][ ]?[0-9]{4}")
  #       result = valid_phones.select { |x| reg.match(x) }
  #
  #       indexer.update_attribute(:phones, result)
  #     end
  #   end
  # end


  # def core_phone_norm
  #   #normalizes phone in core sfdc acts.
  #   cores = Core.where.not(sfdc_ph: nil)
  #   cores.each do |core|
  #     alert = ""
  #     sfdc_ph = core.sfdc_ph
  #     puts "sfdc_ph: #{sfdc_ph}"
  #     norm_ph = phone_formatter(sfdc_ph) #=> via PhoneFormatter
  #
  #     if norm_ph != sfdc_ph
  #       alert = "Alert!"
  #       core.update_attribute(:sfdc_ph, norm_ph)
  #     end
  #     puts "norm_ph: #{norm_ph} #{alert}\n\n"
  #   end
  # end




end
