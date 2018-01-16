#######################################
# CALL: Formatter.new.format_act_name('act_name')
#######################################

class GoogPlace

  def initialize
    @formatter = Formatter.new
  end

  def get_spot(act_name, url)
    act_name = act_name&.gsub(/\s/, ' ')&.strip
    # client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    client = GooglePlaces::Client.new('AIzaSyDX5Sn2mNT1vPh_MyMnNOH5YL4cIWaB3s4')
    uri = URI(url)
    host = uri.host
    host&.gsub!('www.', '')
    query = "#{host}, #{act_name}"

    spot = client.spots_by_query(query)&.first
    if spot.present?
      spot_adr = spot.formatted_address
      if spot_adr.present?
        adr_hsh = format_goog_adr(spot_adr)
      else
        adr_hsh = {adr_sts: 'invalid', street: nil, city: nil, state: nil, zip: nil, adr_pin: nil}
      end
      goog_hsh = { act_name: spot.name, adr: adr_hsh, goog_id: spot.id, place_id: spot.place_id }
      return goog_hsh
    end
  end

  #CALL: GoogPlace.new.format_goog_adr('adr')
  def format_goog_adr(adr)
    if adr.present?
      foreign_country = find_foreign_country(adr)
      if !adr.include?('United States') || foreign_country.present?
        adr_hsh = {adr_sts: 'foreign', street: nil, city: nil, state: nil, zip: nil, adr_pin: nil}
        return adr_hsh
      else
        adr.gsub!('United States', '')
        adr.squeeze(' ')
        adr.strip!

        adrs = adr.split(',').map{|item| item.strip}
        street, city, state, zip, adr_pin = nil, nil, nil, nil, nil

        adrs.each do |adr_part|
          splits = adr_part.split(' ')

          ## Get State and Zip ##
          splits0 = splits&.first
          splits1 = splits&.last
          if splits.length == 2
            state = splits0 if splits0.scan(/[A-Z]/).length == 2
            zip = splits1 if splits1.scan(/[0-9]/).length.in?([5, 9])
            adr_pin = @formatter.generate_adr_pin(street, zip) if street && zip
          end

          ## Get Street and City ##
          street = adr_part if splits.length > 2 && adr_part.scan(/[A-Za-z]/).any? && adr_part.scan(/[0-9]/).any?
          street = @formatter.format_street(street)
          city = adr_part if splits.length < 4 && adr_part.scan(/[A-Za-z]/).any? && !adr_part.scan(/[0-9]/).any?
        end
        adr_hsh = {adr_sts: 'valid', street: street, city: city, state: state, zip: zip, adr_pin: adr_pin}
        return adr_hsh
      end
    end
  end


  #######################################
  # CALL: GoogPlace.new.find_country('string')
  #######################################
  def find_foreign_country(string)
    if string.present?
      countries = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burma", "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo, Democratic Republic of the", "Congo, Republic of the", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Curacao", "Cyprus", "Czechia", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, North", "Korea, South", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territories", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Sint Maarten", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]

      temp_string = string.tr('^A-Za-z', '')&.downcase
      foreign_country = countries.find do |country|
        temp_country = country.tr('^A-Za-z', '')&.downcase
        temp_string.include?(temp_country)
      end

      return foreign_country
    end
  end



end
