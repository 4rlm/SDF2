module ActFormatter

  #Call: Migrator.new.migrate_uni_acts

  # CALL: ActFormatter.format_act_name(act_name)
  def self.format_act_name(act_name)
    if act_name.present?
      puts "act_name: #{act_name}"
      act_name&.gsub!(".", " ")
      act_name&.gsub!(",", " ")

      if act_name.include?('|')
        puts act_name
        name_parts = act_name.split('|')
        act_name = name_parts.first
        puts act_name
      end

      act_name = Formatter.new.letter_case_check(act_name)
      act_name&.strip!
      act_name&.squeeze!(" ")
      act_name = check_brand_in_name(act_name)
      act_name = Formatter.new.check_common_words(act_name)
      puts "act_name: #{act_name}"
      return act_name
    end
  end


  #Call: Migrator.new.migrate_uni_acts

  def self.check_brand_in_name(act_name)
    if act_name.present?
      brands = %w(BMW GMC Kia Ram Mclaren Mercedes-Benz Rolls-Royce)
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
