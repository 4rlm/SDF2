module AddressFormatter

  def self.format_address_hash(address_hash)
    #Call: AddressFormatter.format_address_hash(address_hash)
    address_hash.delete_if { |key, value| value.downcase.include?('meta') }

    if !address_hash.empty?
      address_hash['zip'] = format_zip(address_hash['zip'])
      address_hash['address_pin'] = generate_address_pin(address_hash['street'], address_hash['zip'])
      address_hash.delete_if { |key, value| value.blank? } if !address_hash.empty?
    end

    return address_hash
  end


  def self.format_zip(zip)
    # AddressFormatter.format_zip(zip)
    if zip
      zip_temp = zip.tr('^0-9', '')
      zip = "0#{zip_temp}" if zip_temp.length == 4
      return zip
    end
  end


  def self.generate_address_pin(street, zip)
    # AddressFormatter.generate_address_pin(street, zip)

    address_pin = nil
    if street && zip
      street_parts = street.split(" ")
      street_num = street_parts[0]
      street_num = street_num.tr('^0-9', '')
      new_zip = zip.strip
      new_zip = zip[0..4]
      address_pin = "z#{new_zip}-s#{street_num}"
    end

    return address_pin
  end




  ## NOT USING FULL ADDRESS, BUT DON'T DELETE!
  # def self.generate_full_address(obj)
  #   # AddressFormatter.format_full_address(obj)
  #   addr_hash = { street: obj.street, unit: obj.unit, city: obj.city, state: obj.state, zip: obj.zip }
  #   full_address = addr_hash.values.compact.join(', ')
  #   return full_address
  # end

  ## NOT USING FULL ADDRESS, BUT DON'T DELETE!
  # def self.check_full_address(address_hash)
  #   # AddressFormatter.check_full_address(address_hash)
  #
  #   binding.pry
  #   if !address_hash.empty?
  #     full_address = address_hash.except('address_pin').values.compact.join(', ')
  #     return full_address
  #   end
  # end




  #### REALLY OLD STUFF BELOW.  CONSIDER DELETING LATER ####


    # def acct_pin_gen_helper
    #   cores = Core.where.not(full_address: nil).where(sfdc_zip: nil)
    #   cores.each do |core|
    #     full_address = core.full_address
    #
    #     puts "\n\n#{"-"*40}\n"
    #
    #     if full_address.blank?
    #       puts "Blank"
    #       p full_address
    #       core.update_attribute(:full_address, nil)
    #     else
    #       address_parts = full_address.split(",")
    #       last_part = address_parts[-1].gsub(/[^0-9]/, "")
    #
    #       if !last_part.blank?
    #         if last_part.length == 5
    #           new_zip = last_part
    #           puts "Address: #{full_address}"
    #           puts "new_zip: #{new_zip}"
    #           core.update_attribute(:sfdc_zip, new_zip)
    #         elsif last_part.length == 4
    #           new_zip = "0"+last_part
    #           new_full = address_parts[0...-1].join(",")
    #           new_full_addr = "#{new_full}, #{new_zip}"
    #           puts "new_full_addr: #{new_full_addr}"
    #           puts "new_zip: #{new_zip}"
    #           core.update_attributes(full_address: new_full_addr, sfdc_zip: new_zip)
    #         end
    #
    #       end
    #     end
    #   end
    # end
    #
    #
    # def acct_pin_gen_starter
    #   inputs = Core.where.not(sfdc_street: nil).where.not(sfdc_zip: nil)
    #   # inputs = Location.where.not(street: nil).where.not(postal_code: nil)
    #   # inputs = Who.where.not(registrant_address: nil).where.not(registrant_zip: nil)
    #
    #   inputs.each do |input|
    #     street = input.sfdc_street
    #     zip = input.sfdc_zip
    #     acct_pin = acct_pin_gen(street, zip)
    #     puts "\n\nstreet: #{street}"
    #     puts "zip: #{zip}"
    #     puts "Acct Pin: #{acct_pin}\n#{"-"*40}"
    #     input.update_attribute(:crm_acct_pin, acct_pin)
    #   end
    # end
    #
    #
    # def acct_pin_gen(street, zip)
    #   street_check = street.tr('^0-9', '')
    #   zip_check = zip.tr('^0-9', '')
    #   if (!street_check.blank? && !zip_check.blank?) && (zip_check != "0" && street_check != "0")
    #     if street.include?("DomainsByProxy")
    #       street_cuts = street.split(",")
    #       street = street_cuts[1]
    #     end
    #
    #     if !street.blank?
    #       street_down = street.downcase
    #       if street_down.include?("box")
    #         street_num = street_down
    #       else
    #         street_parts = street.split(" ")
    #         street_num = street_parts[0]
    #       end
    #
    #       street_num = street_num.tr('^0-9', '')
    #       new_zip = zip.strip
    #       new_zip = zip[0..4]
    #       if !new_zip.blank? && !street_num.blank?
    #         acct_pin = "z#{new_zip}-s#{street_num}"
    #       end
    #     end
    #   else
    #     acct_pin = nil
    #   end
    #   acct_pin
    # end
    #
    #
    #
    #
    # def pin_acct_counter
    #   # acct_pin_count = Indexer.select([:acct_pin]).group(:acct_pin).having("count(*) > 1").map.count
    #   # puts "\n#{"-"*30}\nacct_pin_count: #{acct_pin_count}\n#{"-"*30}\n"
    #
    #   acct_pins = Indexer.select([:acct_pin]).group(:acct_pin).having("count(*) > 1")[0..100]
    #   acct_pins.each do |pin|
    #     indexers = Indexer.where(acct_pin: pin.acct_pin).where.not(acct_pin: nil)
    #     puts "--------------------------------"
    #     indexers.each do |indexer|
    #       target_pin = indexer.acct_pin
    #       target_addr = indexer.full_addr
    #       acct = indexer.acct_name
    #       puts "acct: #{acct}"
    #       puts "target_pin: #{target_pin}"
    #       puts "target_addr: #{target_addr}\n\n"
    #     end
    #   end



end
