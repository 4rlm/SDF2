module AddressFormatter

  #CALL: AddressFormatter.format_address_hsh(address_hash)
  def self.format_address_hsh(address_hash)
    address_hash.delete_if { |key, value| value.downcase.include?('meta') }
    if !address_hash.empty?
      address_hash['zip'] = format_zip(address_hash['zip'])
      address_hash['address_pin'] = generate_address_pin(address_hash['street'], address_hash['zip'])
      address_hash.delete_if { |key, value| value.blank? } if !address_hash.empty?
    end
    return address_hash
  end


  #CALL: AddressFormatter.format_zip(zip)
  def self.format_zip(zip)
    zip_temp = zip.tr('^0-9', '')
    zip = "0#{zip_temp}" if zip_temp.length == 4
    return zip
  end


  # CALL: AddressFormatter.generate_address_pin(street, zip)
  def self.generate_address_pin(street, zip)
    address_pin = nil
    street_parts = street.split(" ")
    street_num = street_parts[0]
    street_num = street_num.tr('^0-9', '')
    new_zip = zip.strip
    new_zip = zip[0..4]
    address_pin = "z#{new_zip}-s#{street_num}"
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


end
