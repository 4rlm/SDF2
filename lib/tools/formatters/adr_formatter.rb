module AdrFormatter

  #CALL: Formatter.new.format_adr_hsh(adr_hsh)
  def format_adr_hsh(adr_hsh)
    adr_hsh.delete_if { |key, value| value.blank? } if !adr_hsh.empty?
    adr_hsh&.delete_if { |key, value| value&.downcase&.include?('meta') }

    if adr_hsh.values.compact.present?
      adr_hsh[:street] = format_street(adr_hsh[:street]) if adr_hsh[:street]
      # adr_hsh['state'] = format_state(adr_hsh['state']) if adr_hsh['state']
      if adr_hsh[:state].present?
        state = format_state(adr_hsh[:state])
        adr_hsh[:state] = state if state.present?
        if state == nil && !adr_hsh[:city].present?
          adr_hsh[:city] = adr_hsh[:state]
          adr_hsh[:state] = nil
        elsif state == nil && adr_hsh[:street].present? && adr_hsh[:city].present?
          street = "#{adr_hsh[:street]} #{adr_hsh[:city]}"
          adr_hsh[:street] = street
          adr_hsh[:city] = adr_hsh[:state]
          adr_hsh[:state] = nil
        end
      end

      adr_hsh[:city] = format_city(adr_hsh[:city]) if adr_hsh[:city]
      adr_hsh[:zip] = format_zip(adr_hsh[:zip]) if adr_hsh[:zip]
      adr_hsh[:adr_pin] = generate_adr_pin(adr_hsh[:street], adr_hsh[:zip])
    end

    adr_hsh.delete_if { |key, value| value.blank? } if !adr_hsh.empty?
    return adr_hsh
  end

  def format_city(city)
    city = city&.gsub(/\s/, ' ')&.strip
    city = nil if city&.scan(/[0-9]/)&.any?
    city = nil if city&.downcase&.include?('category')
    city = nil if city&.downcase&.include?('model')
    city = nil if city&.downcase&.include?('make')
    city = nil if city&.downcase&.include?('inventory')

    if city.present?
      street_types = %w(avenue boulevard drive expressway freeway highway lane parkway road route street terrace trail turnpike)
      invalid_city = street_types.find { |street_type| city.downcase.include?(street_type) }
      city = nil if invalid_city.present?

      if city.present?
        st_types = %w(ave blvd dr expy fwy hwy ln pkwy rd rte st ter trl tpke)
        city_parts = city.split(' ')

        invalid_city = city_parts.select do |city_part|
          st_types.find { |st_type| city_part.downcase == st_type }
        end

        city = nil if invalid_city.present?
        return city
      end
    end

    return city
  end

  def format_state(state)
    state = state&.gsub(/\s/, ' ')&.strip

    if state.present?
      state = state.tr('^A-Za-z', '')
      state = nil if state&.length < 2

      if state.length > 2
        states_hsh = { 'Alabama'=>'AL', 'Alaska'=>'AK', 'Arizona'=>'AZ', 'Arkansas'=>'AR', 'California'=>'CA', 'Colorado'=>'CO', 'Connecticut'=>'CT', 'Delaware'=>'DE', 'Florida'=>'FL', 'Georgia'=>'GA', 'Hawaii'=>'HI', 'Idaho'=>'ID', 'Illinois'=>'IL', 'Indiana'=>'IN', 'Iowa'=>'IA', 'Kansas'=>'KS', 'Kentucky'=>'KY', 'Louisiana'=>'LA', 'Maine'=>'ME', 'Maryland'=>'MD', 'Massachusetts'=>'MA', 'Michigan'=>'MI', 'Minnesota'=>'MN', 'Mississippi'=>'MS', 'Missouri'=>'MO', 'Montana'=>'MT', 'Nebraska'=>'NE', 'Nevada'=>'NV', 'New Hampshire'=>'NH', 'New Jersey'=>'NJ', 'New Mexico'=>'NM', 'New York'=>'NY', 'North Carolina'=>'NC', 'North Dakota'=>'ND', 'Ohio'=>'OH', 'Oklahoma'=>'OK', 'Oregon'=>'OR', 'Pennsylvania'=>'PA', 'Rhode Island'=>'RI', 'South Carolina'=>'SC', 'South Dakota'=>'SD', 'Tennessee'=>'TN', 'Texas'=>'TX', 'Utah'=>'UT', 'Vermont'=>'VT', 'Virginia'=>'VA', 'Washington'=>'WA', 'West Virginia'=>'WV', 'Wisconsin'=>'WI', 'Wyoming'=>'WY' }

        state = state.capitalize
        states_hsh.map { |k,v| state = v if state == k }
        state = nil if state&.length != 2
        state = nil if state&.include?('ST')
      end

      state&.upcase!
    end
    return state
  end


  #CALL: Formatter.new.format_zip(zip)
  def format_zip(zip)
    zip = zip&.gsub(/\s/, ' ')&.strip
    if zip.present?
      zip_temp = zip.tr('^0-9', '')
      zip = "0#{zip_temp}" if zip_temp.length == 4
    end
    return zip
  end


  # CALL: Formatter.new.format_street(street)
  def format_street(street)
    street = street&.gsub(/\s/, ' ')&.strip
    if street.present?
      street = nil if street&.include?("(")
      street = nil if street&.include?(")")
      street = nil if street&.include?("[")
      street = nil if street&.include?("]")
      street = nil if street&.downcase&.include?("phone")
      street = nil if street&.downcase&.include?("sales")
      street = nil if street&.downcase&.include?("parts")

      if street.present?

        if street.include?("•")
          street_parts = street.split("•")
          street = street_parts.first
        end

        if street.include?('|')
          street_parts = street.split('|')
          street = street_parts.first
        end

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
        street&.gsub!("|", " ")
        street&.gsub!("•", " ")

        street&.strip!
        street&.squeeze!(" ")
      end
    end

    return street
  end


  # CALL: Formatter.new.generate_adr_pin(street, zip)
  def generate_adr_pin(street, zip)
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
