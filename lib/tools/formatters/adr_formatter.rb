module AdrFormatter

  #CALL: AdrFormatter.format_adr_hsh(adr_hsh)
  def self.format_adr_hsh(adr_hsh)
    adr_hsh&.delete_if { |key, value| value&.downcase.include?('meta') }
    if !adr_hsh.empty?
      adr_hsh['zip'] = format_zip(adr_hsh['zip']) if adr_hsh['zip']
      adr_hsh['street'] = format_street(adr_hsh['street']) if adr_hsh['street']
      adr_hsh['adr_pin'] = generate_adr_pin(adr_hsh['street'], adr_hsh['zip'])
      adr_hsh.delete_if { |key, value| value.blank? } if !adr_hsh.empty?
    end
    return adr_hsh
  end


  #CALL: AdrFormatter.format_zip(zip)
  def self.format_zip(zip)
    zip_temp = zip.tr('^0-9', '')
    zip = "0#{zip_temp}" if zip_temp.length == 4
    return zip
  end

  #Call: Migrator.new.migrate_uni_acts

  # CALL: AdrFormatter.format_street(street)
  def self.format_street(street)

    if street.present?
      street = Formatter.new.letter_case_check(street)
      street = " #{street} " # Adds white space, to match below, then strip.
      street&.gsub!(".", "")

      street&.gsub!(" North ", " N ")
      street&.gsub!(" South ", " S ")
      street&.gsub!(" East ", " E ")
      street&.gsub!(" West ", " W ")

      street&.gsub!(" Ne ", " NE ")
      street&.gsub!(" Nw ", " NW ")
      street&.gsub!(" Se ", " SE ")
      street&.gsub!(" Sw ", " SW ")

      street&.gsub!("Avenue", "Ave")
      street&.gsub!("Boulevard", "Blvd")
      street&.gsub!("Drive", "Dr")
      street&.gsub!("Expressway", "Expy")
      street&.gsub!("Freeway", "Fwy")
      street&.gsub!("Highway", "Hwy")
      street&.gsub!("Lane", "Ln")
      street&.gsub!("Parkway", "Pkwy")
      street&.gsub!("Road", "Rd")
      street&.gsub!("Route", "Rte")
      street&.gsub!("Street", "St")
      street&.gsub!("Terrace", "Ter")
      street&.gsub!("Trail", "Trl")
      street&.gsub!("Turnpike", "Tpke")

      street&.strip!
      street&.squeeze!(" ")

      return street
    end
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


end
