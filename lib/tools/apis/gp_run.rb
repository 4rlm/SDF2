#######################################
#CALL: GpAct.new.start_act_goog
#######################################

module GpRun

  def get_spot(act_name, url)
    act_name = act_name&.gsub(/\s/, ' ')&.strip if act_name.present?

    if url.present?
      uri = URI(url)
      host = uri.host
      host&.gsub!('www.', '')
    end

    begin
      query1 = "#{host}, #{act_name}" if act_name.present? && host.present?
      query2 = act_name if act_name.present?
      query3 = host if host.present?

      # spots = client.spots_by_query(crm_acct, types: ["car_dealer"])
      spot = @client.spots_by_query(query1, types: ["car_dealer"])&.first if !spot.present? && query1
      spot = @client.spots_by_query(query2, types: ["car_dealer"])&.first if !spot.present? && query2
      spot = @client.spots_by_query(query3, types: ["car_dealer"])&.first if !spot.present? && query3
    rescue
      puts "Google Places Error"
      return nil
    end


    if spot.present?
      ## Process Act Name ##
      act_name = spot.name
      act_name&.gsub!('.', ' ')
      act_name&.gsub!(' Of ', ' of ')
      act_name&.gsub!('Saint', 'St')
      act_name&.strip!
      act_name&.squeeze!(" ")

      ## Process Address ##
      spot_adr = spot.formatted_address
      if spot_adr.present?
        adr_hsh = format_goog_adr(spot_adr)
      else
        adr_hsh = {adr_gp_sts: 'Invalid', street: nil, city: nil, state: nil, zip: nil, pin: nil}
      end

      ## Reformat Act Name w/ City and State ##
      city = adr_hsh[:city]
      state = adr_hsh[:state]
      act_name = "#{act_name} in #{city}" if city.present? && !act_name.include?(city)
      act_name = "#{act_name}, #{state}" if state.present? && !act_name.include?(state)
      act_name&.strip!
      act_name&.squeeze!(" ")


      ## Process Industry ##
      industries = spot.types ||= []
      industries -= %w(store point_of_interest establishment car_repair)
      indus = industries.join(' ')

      ## Get Spot Detail ##
      place_id = spot.place_id
      detail = @client.spot(spot.place_id)

      ## Process Website ##
      website = detail&.website
      website = @formatter.format_url(website) if website.present?

      ## Process Phone ##
      phone = detail&.formatted_phone_number
      phone = @formatter.validate_phone(phone)

      ## Create Result Hashes ##
      gp_sts_hsh = {
        place_id: place_id,
        act_gp_sts: nil,
        act_gp_date: Time.now
      }

      gp_hsh = {
        act_name: act_name,
        adr: adr_hsh,
        url: website,
        phone: phone,
        indus: indus,
        gp_sts_hsh: gp_sts_hsh
      }

      gp_hsh.values.compact.present? ? validity = 'Valid:gp' : validity = 'Invalid'
      gp_hsh[:gp_sts_hsh][:act_gp_sts] = validity
      return gp_hsh
    end
  end




  ####################################
  ########## HELPER METHODS ##########
  ####################################


  #CALL: GpApi.new.format_goog_adr('adr')
  def format_goog_adr(adr)
    if adr.present?
      country = adr.split(',').last
      foreign_country = find_foreign_country(country)
      if foreign_country.present?
        adr_hsh = {adr_gp_sts: 'foreign', street: nil, city: nil, state: nil, zip: nil, pin: nil}
        return adr_hsh
      else
        adr.gsub!('United States', '')
        adr.squeeze(' ')
        adr.strip!

        adrs = adr.split(',').map{|item| item.strip}
        street, city, state, zip, pin = nil, nil, nil, nil, nil

        adrs.each do |adr_part|
          splits = adr_part.split(' ')

          ## Get State and Zip ##
          splits0 = splits&.first
          splits1 = splits&.last
          if splits.length == 2
            state = splits0 if splits0.scan(/[A-Z]/).length == 2
            zip = splits1 if splits1.scan(/[0-9]/).length.in?([5, 9])
            pin = @formatter.generate_pin(street, zip) if street && zip
          end

          ## Get Street and City ##
          street = adr_part if splits.length > 2 && adr_part.scan(/[A-Za-z]/).any? && adr_part.scan(/[0-9]/).any?
          street = @formatter.format_street(street)
          city = adr_part if splits.length < 4 && adr_part.scan(/[A-Za-z]/).any? && !adr_part.scan(/[0-9]/).any?
          city&.gsub!('Saint', 'St')
          city&.gsub!('-', ' ')

          street&.strip!
          street&.squeeze!(" ")
          city&.strip!
          city&.squeeze!(" ")
          state&.strip!
          state&.squeeze!(" ")
          zip&.strip!
          zip&.squeeze!(" ")
        end
        adr_hsh = {adr_gp_sts: 'Valid', street: street, city: city, state: state, zip: zip, pin: pin}
        return adr_hsh
      end
    end
  end


  #######################################
  # CALL: GpApi.new.find_country('string')
  #######################################
  def find_foreign_country(act_name)
    if act_name.present?
      countries = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burma", "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo, Democratic Republic of the", "Congo, Republic of the", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Curacao", "Cyprus", "Czechia", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, North", "Korea, South", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territories", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Sint Maarten", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]

      temp_act_name = act_name.tr('^A-Za-z', '')&.downcase
      foreign_country = countries.find do |country|
        temp_country = country.tr('^A-Za-z', '')&.downcase
        temp_act_name.include?(temp_country)
      end
      return foreign_country
    end
  end





  #######################################
  ######### HELPER METHODS BELOW ########
  #######################################


  def capitalize_string(string)
    if string.present?
      ## Capitalize All Act_Name words except brands and exclusion words.
      brands = @formatter.check_brand_in_name(act_name)&.split(' ')
      exclusions = %w(in of)
      act_name_parts = act_name.split(' ')
      act_name_parts.map do |name_part|
        brands.each do |brand|
          if !name_part.include?(brand) && !exclusions.any? {|exl| name_part == exl }
            name_part.capitalize!
          end
        end
      end
      act_name = act_name_parts.join(' ')
      act_name&.gsub!('Gmc', 'GMC')
      puts "\n\n===================="
      puts act_name
      binding.pry
      return string
    end
  end




end
