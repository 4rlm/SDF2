module ActFormatter

  ## Temporary Call:
  #Call: Migrator.new.migrate_uni_acts

  # CALL: Formatter.new.format_act_name('act_name')
  def format_act_name(act_name)
    if act_name.present?

      # TESTING!!! #
      # act_name = "George Gee Kia Coeur D'Alene"

      puts "\n\n\n=========================\n\n"
      puts act_name
      act_name = act_name&.gsub(/\s/, ' ')&.strip

      act_name = act_name.split("d/b/a")&.last
      act_name = act_name.split('www')&.first
      act_name = act_name.split('/').join(' ')

      act_name&.gsub!("2020", " ")
      act_name&.gsub!("2019", " ")
      act_name&.gsub!("2018", " ")
      act_name&.gsub!("2017", " ")
      act_name&.gsub!("2016", " ")
      act_name&.gsub!("2015", " ")
      act_name&.gsub!("2014", " ")
      act_name&.gsub!("Serving", " ")
      act_name&.gsub!("New & Used", " ")
      act_name&.gsub!("Used", " ")
      act_name&.gsub!("used", " ")
      act_name&.gsub!("Your", " ")
      act_name&.gsub!("Its", " ")
      act_name&.gsub!("Preferred", " ")
      act_name&.gsub!("Inventory", " ")
      act_name&.gsub!("Search", " ")
      act_name&.gsub!("Opens in a New Window", " ")
      act_name&.gsub!("The Best", " ")
      act_name&.gsub!("Selection", " ")
      act_name&.gsub!("Welcome to", " ")
      act_name&.gsub!("Welcomes", " ")
      act_name&.gsub!("Welcome", " ")
      act_name&.gsub!("Customers", " ")
      act_name&.gsub!("Window", " ")
      act_name&.gsub!("Opens", " ")
      act_name&.gsub!(" New ", " ")
      act_name&.gsub!(" new ", " ")
      act_name&.gsub!("Featuring", " ")
      act_name&.gsub!("For Sale", " ")
      act_name&.gsub!("•", " ")

      act_name&.gsub!("Incorporated", " ")
      act_name&.gsub!("Inc", " ")
      act_name&.gsub!("INC", " ")
      act_name&.gsub!("LLC", " ")
      act_name&.gsub!("Llc", " ")
      act_name&.gsub!("(", " ")
      act_name&.gsub!(")", " ")
      act_name&.gsub!("[", " ")
      act_name&.gsub!("]", " ")
      act_name&.gsub!("FLM", "Ford Lincoln Mercury")
      act_name&.gsub!("Ford-Lincoln", "Ford Lincoln")
      act_name&.gsub!("Lincoln-Mercury", "Lincoln Mercury")
      # act_name.gsub!(" - ", "-")

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
        act_name.strip!
        act_name.squeeze!(" ")
        act_name = act_name.split(' ')&.each { |el| el[0] = el[0]&.upcase}&.join(' ')
        act_name = check_brand_in_name(act_name)

        act_name = Formatter.new.check_conjunctions(act_name) if act_name.present?
        act_name = act_name&.split(' ')&.each { |el| el[2] = el[2]&.upcase if el.downcase[0..1] == 'mc'}&.join(' ')
        act_name = act_name&.split(' ')&.each { |el| el[2] = el[2]&.upcase if el[1] == "'"}&.join(' ')

        act_name&.gsub!(".", " ")
        act_name&.gsub!(",", " ")
        act_name&.gsub!("amp;", " ")
        act_name&.gsub!(";", " ")
        act_name&.strip!
        act_name&.squeeze!(" ")
      end

      puts act_name
      # sleep(2)
      # binding.pry

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
