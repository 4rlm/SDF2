#CALL: ContScraper.new.start_cont_scraper

class CsHelper # Contact Scraper Helper Method
  include FormatPhone
  # format_phone(phone)

  def initialize
    @formatter = Formatter.new
    # @rts_manager = RtsManager.new
    # @as_manager = AsManager.new  ## Deprecated.  Should use Formatter or AsHelper.new
  end

  # In case, template scraper wants to use this way.
  # Just add this line: `cs_hsh_arr = @helper.standard_scraper(staffs)`
  def standard_scraper(staffs)
    cs_hsh_arr = []

    if staffs.any?
      staffs.each do |staff|
        staff_hash = {}
        # Get name, job_desc, phone
        info_ori = staff.text.split("\n").map do |el|
          el = el.delete("\t")
          el = el.delete(",")
          el = el.delete("\r")
          el = el.strip
        end
        infos = info_ori.delete_if {|el| el.blank?}
        infos = infos.uniq
        infos.each { |info| infos -= junk_detector(info) }

        ## Structured to prevent job_desc going to full_name
        infos.each do |info|
          job_desc = job_detector(info)

          if job_desc.present?
            staff_hash[:job_desc] = job_desc
          else
            full_name = name_detector(info)
            staff_hash[:full_name] = full_name if full_name.present?
          end

          phone_hsh = phone_detector(info)
          staff_hash[:phone] = phone_hsh[:phone] if phone_hsh.present?
        end

        ## Get email
        data = staff.inner_html
        regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
        email_reg = regex.match(data)
        staff_hash[:email] = email_reg.to_s if email_reg

        cs_hsh_arr << staff_hash
      end
    end

    return cs_hsh_arr
  end
  ##################################

  def name_detector(str)
    if str.length < 48
      str.gsub!(/\W/,' ')
      parts = str.split(" ")
      name_reg = Regexp.new("[@./0-9]")
      return str if !str.scan(name_reg).any? && (parts.length < 5 && parts.length > 1)
    end
    return nil
  end


  def phone_detector(str)
    if str.length < 48
      phone = @formatter.format_phone(str)
      return {phone: phone, str: str} if phone.present?
    end
    return nil
  end

  def junk_detector(str)
    junks = %w(= [ ] : ; @ ! ? { } about account address analyt box call change chat check choice click comment contact country custom direction display email float form give google great hide hour info input load meet more name none our phone policy priva question quick quote rate ready saving src staff strict title today type use)
    down_str = str.downcase
    junks.each { |junk| return [str] if down_str.include?(junk) }
    return []
  end

  def job_detector(str)
    if str.length < 48
      jobs = %w(account admin advis agent assist associ attend bdc busin car cashier center ceo certified chief clerk consultant coordinator cto customer dealer detail develop direct driver engineer estimator executive finan fleet general gm intern inventory leasing license mainten manage market new office online operat own part pres principal professional receiv reception recruit represent sales scheduler service shipping shop shuttle specialist superv support tech trainer transmission transportation ucm used varia vice vp warranty write)

      down_str = str.downcase
      jobs.each { |job| return str if down_str.include?(job) }
    end
    return nil
  end

  def prep_create_staffer(cs_hsh_arr)
    cs_hsh_arr.each do |staff_hash|

      # Clean & Divide full name
      if staff_hash[:full_name]
        name_parts = staff_hash[:full_name].split(" ").each { |name| name&.strip&.capitalize! }
        staff_hash[:first_name] = name_parts&.first&.strip
        staff_hash[:last_name] = name_parts&.last&.strip
        staff_hash[:full_name] = name_parts.join(' ')
      elsif staff_hash[:first_name] && staff_hash[:last_name]
        staff_hash[:first_name] = staff_hash[:first_name]&.strip&.capitalize
        staff_hash[:last_name] = staff_hash[:last_name]&.strip&.capitalize
        staff_hash[:full_name] = "#{staff_hash[:first_name]} #{staff_hash[:last_name]}"
      end

      # Clean email address
      if email = staff_hash[:email]
        email.gsub!(/mailto:/, '') if email.include?("mailto:")
        staff_hash[:email] = email.strip
      end

      # Clean Job Desc
      staff_hash[:job_desc] = staff_hash[:job_desc]&.strip

      # Clean Phone
      phone = format_phone(staff_hash[:phone]&.strip)
      staff_hash[:phone] = @formatter.validate_phone(phone) if phone.present?

      ## Remove Blanks
      staff_hash.delete_if { |key, value| value.blank? } if !staff_hash.empty?
    end

    cs_hsh_arr = remove_invalid_cs_hsh(cs_hsh_arr)
    cs_hsh_arr.delete_if(&:empty?)&.uniq!
    return cs_hsh_arr
  end


  def consolidate_cs_hsh_arr(staffs_arr)
    cs_hsh_arr = []
    staffs_arr.each do |staffs|
      temp_cs_hsh_arr = standard_scraper(staffs)
      temp_cs_hsh_arr.each { |temp_cs_hsh| cs_hsh_arr << temp_cs_hsh.sort.to_h }
    end

    cs_hsh_arr.delete_if(&:empty?)&.uniq!
    cs_hsh_arr = prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?
    return cs_hsh_arr
  end


  def remove_invalid_cs_hsh(cs_hsh_arr)
    cs_hsh_arr.delete_if { |hsh| !hsh[:full_name].present? }.uniq! if cs_hsh_arr.any?
    return cs_hsh_arr
  end

  def email_cleaner(str)
    str = str&.downcase
    str ? str.gsub(/^mailto:/, '') : str
  end

  # def include_neg(str)
  #   negs = %w(: . @ ! ? address call change chat choice contact country custom direction display give great hide hour float load none policy privacy quick quote rate ready saving src strict today use)
  #   negs.each do |neg|
  #     return true if str.include?(neg)
  #   end
  #   return false
  # end

end
