#CALL: GpStart.new.start_gp_act
######### Delayed Job #########
# $ rake jobs:clear

module GpRun

  def get_spot(act_name, url, gp_id)

    begin

      if gp_id.present?
        spot = @client.spot(gp_id)
      else

        if url.present?
          uri = URI(url)
          host = uri.host
          host&.gsub!('www.', '')
        end

        query1 = "#{host}, #{act_name}" if act_name.present? && host.present?
        query2 = act_name if act_name.present?
        query3 = host if host.present?

        spot = @client.spots_by_query(query1, types: ["car_dealer"])&.first if !spot.present? && query1
        spot = @client.spots_by_query(query2, types: ["car_dealer"])&.first if !spot.present? && query2
        spot = @client.spots_by_query(query3, types: ["car_dealer"])&.first if !spot.present? && query3
      end

    rescue => e
      puts "Google Places Error"
      # puts e.error
      binding.pry
      return nil
    end

    if spot.present?
      ## Process Act Name ##
      act_name = spot.name
      act_name&.gsub!('.com', ' ')
      act_name&.gsub!('.net', ' ')
      act_name&.gsub!('.co', ' ')
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
        adr_hsh = {street: nil, city: nil, state: nil, zip: nil}
      end

      ## Process Industry ##
      industries = spot.types ||= []
      industries -= %w(store point_of_interest establishment car_repair)
      gp_indus = industries.join(' ')

      ## Get Spot Detail ##
      place_id = spot.place_id
      detail = @client.spot(spot.place_id)

      website = detail&.website
      phone = detail&.formatted_phone_number
      website = @formatter.format_url(website) if website.present?
      phone = @formatter.validate_phone(phone)

      ## Create Result Hashes ##
      gp_hsh = { act_name: act_name,
        street: adr_hsh[:street],
        city: adr_hsh[:city],
        state: adr_hsh[:state],
        zip: adr_hsh[:zip],
        gp_sts: adr_hsh[:gp_sts],
        url: website,
        phone: phone,
        gp_indus: gp_indus,
        gp_id: place_id,
        gp_date: Time.now }

      gp_hsh.values.compact.present? ? validity = 'Valid' : validity = 'Invalid'
      gp_hsh[:gp_sts] = validity

      gp_hsh = check_http(gp_hsh, url) if url.present?
      return gp_hsh
    end
  end


  ########## HELPER METHODS ##########
  #CALL: GpStart.new.start_gp_act

  #Call: GpApi.new.check_http(gp_hsh, web_url)
  def check_http(gp_hsh, web_url)
    gp_url = gp_hsh[:url] if gp_hsh.present?
    return gp_hsh if (!gp_url.present? && !web_url.present?)
    gp_url = @formatter.format_url(gp_url)
    web_url = @formatter.format_url(web_url)

    return gp_hsh if (gp_url == web_url)
    gp_uri_hsh = parse_url(gp_url)
    web_uri_hsh = parse_url(web_url)

    return gp_hsh if (!gp_uri_hsh.present? && !web_uri_hsh.present?)
    return gp_hsh if (gp_uri_hsh[:host] != web_uri_hsh[:host])
    gp_scheme = gp_uri_hsh[:scheme]
    web_scheme = web_uri_hsh[:scheme]
    return gp_hsh if (gp_scheme == web_scheme)
    gp_hsh[:url] = web_url if (web_scheme.length > gp_scheme.length)

    return gp_hsh
  end

  def parse_url(url)
    if url.present?
      uri = URI(url)
      if uri.present?
        uri_hsh = {scheme: uri.scheme, host: uri.host}
        return uri_hsh
      end
    end
  end


  #CALL: GpApi.new.format_goog_adr('adr')
  def format_goog_adr(adr)
    if adr.present?
      country = adr.split(',').last
      foreign_country = find_foreign_country(country)
      if foreign_country.present?
        adr_hsh = {gp_sts: 'Invalid', street: nil, city: nil, state: nil, zip: nil}
        return adr_hsh
      else
        adr.gsub!('United States', '')
        adr.gsub!('USA', '')
        adr.squeeze(' ')
        adr.strip!

        adrs = adr.split(',').map{|item| item.strip}
        street, city, state, zip = nil, nil, nil, nil

        adrs.each do |adr_part|
          splits = adr_part.split(' ')

          ## Get State and Zip ##
          splits0 = splits&.first
          splits1 = splits&.last
          if splits.length == 2
            state = splits0 if splits0.scan(/[A-Z]/).length == 2
            zip = splits1 if splits1.scan(/[0-9]/).length.in?([5, 9])
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

        adr_hsh = {gp_sts: nil, street: street, city: city, state: state, zip: zip}
        return adr_hsh
      end
    end
  end

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

  ######### HELPER METHODS BELOW ########

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
