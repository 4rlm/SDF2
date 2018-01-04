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

      act_name = act_name.split("d/b/a")&.last
      act_name = act_name.split('www')&.first
      act_name = act_name.split('/').join(' ')
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
      act_name.gsub!(" - ", "-")
      act_name = act_name.split('-').map {|el| el.capitalize }.join('-')
      act_name.scan(/\d+|[a-zA-Z]+/).join(' ') if !act_name.include?('-')

      act_parts = act_name.split(' ')
      if act_parts.length < 2 && !act_name.include?('-')
        act_name = Formatter.new.cross_ref_all(act_name)
      end

      if act_name.include?('|')
        name_parts = act_name.split('|')
        act_name = name_parts.first
      end

      act_name = Formatter.new.letter_case_check(act_name)
      act_name.strip!
      act_name.squeeze!(" ")
      act_name = act_name.split(' ').each { |el| el[0] = el[0].upcase}.join(' ')
      act_name = check_brand_in_name(act_name)

      act_name = Formatter.new.check_conjunctions(act_name) if act_name.present?
      act_name = act_name&.split(' ')&.each { |el| el[2] = el[2].upcase if el.downcase[0..1] == 'mc'}.join(' ')
      act_name = act_name&.split(' ')&.each { |el| el[2] = el[2].upcase if el[1] == "'"}.join(' ')

      act_name&.gsub!(".", " ")
      act_name&.gsub!(",", " ")
      act_name&.gsub!("amp;", " ")
      act_name&.gsub!(";", " ")
      act_name&.strip!
      act_name&.squeeze!(" ")

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
