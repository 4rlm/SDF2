#######################################
#CALL: ActScraper.new.start_act_scraper
#######################################

module ActFormatter

  # CALL: Formatter.new.format_act_name('act_name')
  def format_act_name(act_name)
    if act_name.present?
      puts "======="
      puts act_name
      act_name = act_name&.gsub(/\s/, ' ')&.strip
      act_name = act_name.split(' ').uniq.join(' ')

      ## Removes Punctuation Chars from Act_Name ##
      punct_invalid_list = [",", "&", ":", ";", "," ".", "(", ")", "[", "]", "•", "!"]
      punct_invalid_list.each { |inval| act_name&.gsub!(inval, ' ') }

      ## Removes Phone from Act_Name ##
      act_name = remove_phones_from_text(act_name)

      ## Gsub City Abreviations before running remove_invalids
      act_name&.gsub!("Sprgs", "Springs")
      act_name&.gsub!("Mtn", "Mountain")
      act_name&.gsub!('Ft', 'Fort')

      ## Gets City Name from Act_Name ##
      found_city_hsh = remove_city_from_act_name(act_name)
      found_city = found_city_hsh[:found_city]
      act_name = found_city_hsh[:act_name]

      ## Remove All Additional City Names from Act_Name, and gets found_city if above returned nil. ##
      inval_hsh = remove_invalids(act_name, get_cities)
      found_city = inval_hsh[:found] if !found_city
      act_name = inval_hsh[:act_name]

      ## Removes False-Positive State Abrevs from Act_Name ##
      act_name.split(' ').each do |act_name_part|
        act_name_part_dwn = act_name_part.downcase
        ['in', 'co', 'mt', 'me'].each do |inval|
          if inval.downcase == act_name_part_dwn
            act_name.gsub!(act_name_part, '')
          end
        end
      end

      ## Gets State from Act_Name ##
      state_parts = act_name.split(' ')
      state_hsh = find_states(state_parts)
      state_long = state_hsh[:state_long]
      state_short = state_hsh[:state_short]

      act_name = act_name.split("d/b/a")&.last
      act_name = act_name.split('www')&.first
      act_name = act_name.split('/').join(' ')

      if act_name.include?('|')
        name_parts = act_name.split('|')
        act_name = name_parts.first
      end

      if act_name.include?('- a ')
        name_parts = act_name.split('- a ')
        act_name = name_parts.first
      end

      if act_name.include?('- A ')
        name_parts = act_name.split('- A ')
        act_name = name_parts.first
      end

      if act_name.include?(' - ')
        name_parts = act_name.split(' - ')
        act_name = name_parts.first
      end

      if act_name.include?(' near ')
        name_parts = act_name.split(' near ')
        act_name = name_parts.first
      end

      act_name = act_name.split('-').map {|el| el.capitalize }.join('-')
      act_name.scan(/\d+|[a-zA-Z]+/).join(' ') if !act_name.include?('-')

      act_parts = act_name.split(' ')
      if act_parts.length < 2 && !act_name.include?('-')
        act_name = Formatter.new.cross_ref_all(act_name)
      end

      act_name = Formatter.new.letter_case_check(act_name) if act_name.present?

      if act_name.present?
        act_name = act_name.split(' ')&.each { |el| el[0] = el[0]&.upcase}&.join(' ')
        act_name = check_brand_in_name(act_name)

        act_name = Formatter.new.check_conjunctions(act_name) if act_name.present?
        act_name = act_name&.split(' ')&.each { |el| el[2] = el[2]&.upcase if el.downcase[0..1] == 'mc'}&.join(' ')

        apos_index = act_name&.index("'")
        if apos_index && (act_name[apos_index-1]&.scan(/[A-Z]/)&.any? || (act_name[apos_index-2] && act_name[apos_index-2] == ' '))
          act_name[apos_index+1] = '' if act_name[apos_index+1] == ' '
          act_name[apos_index+1] = act_name[apos_index+1].upcase
          act_name
        end

        #######################################
        #CALL: ActScraper.new.start_act_scraper
        #######################################
        more_invalid_list = ["One On One", "one on", "One On", "2017-2018"]
        more_invalid_list.each { |inval| act_name&.gsub!(inval, " ") }
        invalid_list = %w(2014 2015 2016 2017 2018 2019 2020 amp approved customers featuring inc incorporated inventory its llc opens preferred search selection serving welcome welcomes window your used co mt car cars source driving heartland since 1923 has ready for next test drive bad credit loans loan dealership dealer pre-owned preowned pre owned own metro alternative personal service parts part drivers driver parish provider automotive trucks suvs truck suv new selling vehicles vehicle full buy luxury sedans sedan financing finance certified near serves beyond specials huge meet best sales sale welcome trusted trust township shoppers shop visit premiere here save pay dealership dealer deal now with for and also by in at the is of a to)

        inval_hsh = remove_invalids(act_name, invalid_list)
        act_name = inval_hsh[:act_name]
        act_name&.gsub!("Orleans", " New Orleans ")
        act_name&.gsub!("Flm", " FLM ")
        act_name&.gsub!("Ford-Lincoln", " FLM ")
        act_name&.gsub!("Ford-Lincoln-Mercury", " FLM ")
        act_name&.gsub!("Ford Lincoln Mercury", " FLM ")
        act_name&.gsub!("Lincoln-Mercury", " FLM ")
        act_name&.gsub!("Lincoln ", " FLM ")
        act_name&.gsub!("Ford ", " FLM ")
        act_name&.gsub!("Mercury", " FLM ")
        act_name&.gsub!("Chrysler Dodge Jeep Ram", " CDJR ")
        act_name&.gsub!("Chrysler Dodge Jeep" " CDJR ")
        act_name&.gsub!("Chrysler Jeep Dodge", " CDJR ")
        act_name&.gsub!("Chevy" " Chevrolet ")
        act_name&.gsub!("Chevrolet-Buick", " Chevrolet Buick ")
        act_name = act_name[0..45] if act_name

        if found_city.present? && (state_long.present? || state_short.present?)
          invalid_list = [state_long, state_long.downcase, state_short, state_short.capitalize, state_short.downcase]
          inval_hsh = remove_invalids(act_name, invalid_list)
          act_name = inval_hsh[:act_name] if inval_hsh.present?
          act_name = "#{act_name} Dealership in #{found_city}, #{state_short}"
        elsif state_long.present? || state_short.present?
          invalid_list = [state_long, state_long.downcase, state_short, state_short.capitalize, state_short.downcase]
          inval_hsh = remove_invalids(act_name, invalid_list)
          act_name = inval_hsh[:act_name] if inval_hsh.present?
          act_name = "#{act_name} Dealership in #{state_short}"
        elsif found_city.present?
          act_name = "#{act_name} Dealership in #{found_city}"
        end

        act_name&.strip!
        act_name&.squeeze!(" ")
        act_name = act_name.split(' ').reverse.uniq.reverse.join(' ') if act_name.present?

        act_name
      end

      puts "======="
      puts act_name
      binding.pry

      return act_name
    end
  end


  #Call: Migrator.new.migrate_uni_acts

  # CALL: Formatter.new.check_brand_in_name(act_name)
  def check_brand_in_name(act_name)
    if act_name.present?
      brands = %w(CDJR CDJ CJDR BMW FIAT GMC Kia Mclaren Mercedes-Benz MINI Rolls-Royce LLC)
      act_name_parts = act_name.split(' ')
      act_name_parts.map do |act|
        if act.scan(/[a-zA-Z]/).any?
          brands.each do |brand|
            if act.downcase.include?(brand.downcase)
              act_name_parts = act_name_parts&.join(' ')&.gsub(act, brand)&.split(' ')
            end
          end
        end
      end
      act_name = act_name_parts.join(' ')
      return act_name
    end
  end


end
