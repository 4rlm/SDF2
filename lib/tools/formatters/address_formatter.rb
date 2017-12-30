module AdrFormatter

  #CALL: AdrFormatter.format_adr_hsh(adr_hash)
  def self.format_adr_hsh(adr_hash)
    adr_hash&.delete_if { |key, value| value&.downcase.include?('meta') }
    if !adr_hash.empty?
      adr_hash['zip'] = format_zip(adr_hash['zip']) if adr_hash['zip']
      adr_hash['adr_pin'] = generate_adr_pin(adr_hash['street'], adr_hash['zip'])
      adr_hash.delete_if { |key, value| value.blank? } if !adr_hash.empty?
    end
    return adr_hash
  end


  #CALL: AdrFormatter.format_zip(zip)
  def self.format_zip(zip)
    zip_temp = zip.tr('^0-9', '')
    zip = "0#{zip_temp}" if zip_temp.length == 4
    return zip
  end


  # CALL: AdrFormatter.generate_adr_pin(street, zip)
  def self.generate_adr_pin(street, zip)
    if street && zip
      adr_pin = nil
      street_parts = street.split(" ")
      street_num = street_parts[0]
      street_num = street_num.tr('^0-9', '')
      new_zip = zip.strip
      new_zip = zip[0..4]
      adr_pin = "z#{new_zip}-s#{street_num}"
      return adr_pin
    end
  end



  ## NOT USING FULL ADDRESS, BUT DON'T DELETE!

  # def self.generate_full_adr(obj)
  #   # AdrFormatter.format_full_adr(obj)
  #   addr_hash = { street: obj.street, unit: obj.unit, city: obj.city, state: obj.state, zip: obj.zip }
  #   full_adr = addr_hash.values.compact.join(', ')
  #   return full_adr
  # end

  ## NOT USING FULL ADDRESS, BUT DON'T DELETE!
  # def self.check_full_adr(adr_hash)
  #   # AdrFormatter.check_full_adr(adr_hash)
  #
  #   binding.pry
  #   if !adr_hash.empty?
  #     full_adr = adr_hash.except('adr_pin').values.compact.join(', ')
  #     return full_adr
  #   end
  # end


end
