#CALL: ContScraper.new.start_cont_scraper

class CsHelper # Contact Scraper Helper Method
  include FormatPhone
  # format_phone(phone)

  def initialize
    @formatter = Formatter.new
    # @rts_manager = RtsManager.new
    # @as_manager = AsManager.new  ## Deprecated.  Should use Formatter or AsHelper.new
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


  # In case, template scraper wants to use this way.
  # Just add this line: `cs_hsh_arr = @helper.standard_scraper(staffs)`
  #CALL: ContScraper.new.start_cont_scraper
  def standard_scraper(staffs)
    cs_hsh_arr = []

    if staffs.any?
      staffs.each do |staff|
        begin
          staff_texts = staff.text
          # puts staff_texts
          staff_texts.gsub!("\n", '  ')
          staff_texts = force_utf_encoding(staff_texts) ## Removes non-utf8 chars.
          # puts staff_texts.inspect

          ##########################
          # Get name, job_desc, phone
          # info_ori = staff.text.split("\n").map do |el|
          #   el = el.delete("\t")
          #   el = el.delete("\r")
          # end

          # infos = info_ori.delete_if {|el| el.blank?}
          # infos = infos.uniq
          # infos.each { |info| infos -= junk_detector(info) }

          ## Structured to prevent job_desc going to full_name
          staff_hash = {}
          staff_texts.each do |staff_text|
            staff_text.squeeze!(' ')
            staff_text.strip!
            job_desc = job_detector(staff_text)

            if job_desc.present?
              staff_hash[:job_desc] = job_desc
            else
              full_name = name_detector(staff_text)
              staff_hash[:full_name] = full_name if full_name.present?
            end

            phone_hsh = phone_detector(staff_text)
            if phone_hsh.present?
              phone = phone_hsh[:phone]
              phone = @formatter.validate_phone(phone) if phone.present?
              staff_hash[:phone] = phone
            end
            # puts staff_hash.inspect
          end

          ## Get email
          data = staff.inner_html
          regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
          email_reg = regex.match(data)
          staff_hash[:email] = email_reg.to_s if email_reg

          if staff_hash[:job_desc] && !staff_hash[:full_name]
            temp_infos = staff_hash[:job_desc]&.split(' ')

            temp_infos.each do |info|
              info_parts = info.split(' ')
              info_parts.each do |info_part|
                if info_part.length > 7 && !info.include?('Mc')
                  if (info_part.scan(/[A-Z]/).count > 1) && (info_part.scan(/[a-z]/).count > 1)
                    name_and_job = info_part.split(/(?=[A-Z])/)
                    temp_infos = temp_infos.map {|el| el.gsub(info_part, name_and_job.join(' '))}.join(' ').split(' ')
                    name = name_and_job.first
                    div1 = temp_infos.index(name)

                    name_arr = temp_infos[0..div1]
                    name_str = name_arr.join(' ').squeeze(' ').strip
                    job_str = (temp_infos - name_arr).join(' ').squeeze(' ').strip
                    staff_hash[:job_desc] = job_str if job_str.present?
                    staff_hash[:full_name] = name_str if name_str.present?

                    # puts staff_hash.inspect
                  end
                end
              end
            end
          end

          #CALL: ContScraper.new.start_cont_scraper
          if staff_hash[:job_desc] && !staff_hash[:full_name]
            orig_job_desc = staff_hash[:job_desc]

            orig_job_desc&.gsub!(/\W/,' ')&.squeeze!(' ')
            name_desc_parts = orig_job_desc&.split(' ')
            name_desc_parts&.delete_if {|x| x.length < 3}

            staff_hash[:full_name] = name_desc_parts[0..1]&.join(' ')
            staff_hash[:job_desc] = name_desc_parts[2..-1]&.join(' ')
            # puts staff_hash.inspect
            # binding.pry

            ## Might need to write code to swap full_name and job_desc is full_name includes below....
            # titles = %w(and asst consultant director finance general internet manager marketing of parts pre-owned president sales service special vice)
          end

          cs_hsh_arr << staff_hash
        rescue
          # return {}
        end
      end
    end

    # puts cs_hsh_arr
    return cs_hsh_arr
  end


  ##################################
  def force_utf_encoding(text)
    if text.present?
      step1 = text.delete("^\u{0000}-\u{007F}")&.strip
      step1.gsub!('Phone', ',')
      step1.gsub!('phone', ',')
      step2 = step1&.split(',')
      step3 = step2&.map! {|str| str.split('  ') }
      step4 = step3&.flatten
      step5 = step4&.reject(&:blank?)
      # puts step5.inspect
      return step5
    end
  end
  ##################################

  def job_detector(str)
    if str.length > 48 || str.include?('@') || str&.scan(/[0-9]/).any?
      return nil
    else
      jobs = %w(account admin advis agent assist associ attend bdc brand busin car cashier center ceo certified chief clerk consultant coordinat cto customer dealer detail develop direct driver engineer estimator executive finan fleet general gm intern inventory leasing license mainten manage market new office online operat own part pres principal professional receiv reception recruit represent sales scheduler service shipping shop shuttle special superv support tech trainer transmission transportation ucm used varia vice vp warranty write)

      parts = str.split(' ')
      clean_str = []
      parts.each do |part|
        part = part.tr('^A-Za-z', '')
        clean_str << part if part&.length > 1
      end
      str = clean_str.join(' ')

      down_str = str.downcase
      res = jobs.find { |job| down_str.include?(job) }
      return str if res.present?
    end
  end


  def name_detector(str)
    banned = ['contact', ' me', ' by', 'phone', ' and', 'mail']
    binding.pry
    return nil if banned.find { |ban| str.include?(ban) }.present?

    if str.length > 48 || str.include?('@') || str.include?(' and') || str&.scan(/[0-9]/).any?
      return nil
    else
      str.gsub!(/\W/,' ')
      parts = str.split(' ')
      name_reg = Regexp.new("[@./0-9]")
      return nil if str.scan(name_reg).any? || (parts.length > 3 || parts.length < 2)

      clean_str = []
      parts.each do |part|
        part = part.tr('^A-Za-z', '')
        clean_str << part if part&.length > 1
      end
      str = clean_str.join(' ')

      return str
    end
  end


  def phone_detector(str)
    if str&.length < 48
      str = str.split('ext')&.first&.strip
      return nil if !str&.scan(/[0-9]/)&.length.in?([10, 11])
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
      job_desc = staff_hash[:job_desc]
      if job_desc.present?
        job_desc.gsub!('Español', '')
        job_desc.squeeze(' ')
        job_desc.strip!
        job_desc = nil if job_desc.scan(/[0-9]/)&.any?
        staff_hash[:job_desc] = job_desc
        staff_hash[:job_title] = get_job_title(job_desc) if job_desc
        # puts "job_desc: #{job_desc}"
        # puts "job_title: #{staff_hash[:job_title]}"
        # binding.pry if staff_hash[:job_title].present?
      end

      # Clean Phone
      phone = format_phone(staff_hash[:phone]&.strip)
      phone = @formatter.validate_phone(phone) if phone.present?
      phone = nil if phone && (phone[1] == '0' || phone[1] == '1')
      phone = nil if phone&.scan(/[A-Za-z]/)&.any?
      staff_hash[:phone] = phone

      ## Remove Blanks
      staff_hash.delete_if { |key, value| value.blank? } if !staff_hash.empty?
    end

    cs_hsh_arr = remove_invalid_cs_hsh(cs_hsh_arr)
    cs_hsh_arr.delete_if(&:empty?)&.uniq!
    return cs_hsh_arr
  end

  ## Reformats all Cont DB job_desc to job_title
  # #CALL: CsHelper.new.temper_get_job_title
  # def temper_get_job_title
  #   Cont.where.not(job_desc: nil).each do |cont|
  #     job_desc = cont.job_desc
  #     job_title = get_job_title(job_desc)
  #     puts "job_desc: #{job_desc}"
  #     puts "job_title: #{job_title}"
  #     cont.update(job_title: job_title)
  #   end
  # end

  def get_job_title(job_desc)
    if job_desc.present?
      job_desc.gsub!('-', ' ')
      job_desc.gsub!('/', ' ')
      job_desc.gsub!('.', ' ')
      job_desc = job_desc.split(' ').map(&:capitalize).join(' ')

      swaps = {Assisant: 'Asst', Person: 'Rep', Consultant: 'Rep', Receivable: 'Payable', Vehicle: 'Car', 'Pre-Owned' => 'Used', Manager: 'Mgr', Brand: 'Sales', Technologist: 'Technician', Exchange: 'Sales', Tech: 'Technician', Agent: 'Rep', Advisor: 'Rep', Representative: 'Rep', Genius: 'Sales Rep', 'Business Development Center' => 'BDC', 'Business Development' => 'BDC', Operator: 'Rep', Coordinator: 'Rep', Mechanic: 'Technician', Associate: 'Rep', Product: 'Sales', Specialist: 'Rep', 'Chief Operations Officer' => 'COO', Truck: 'Sales', Care: 'Service', Client: 'Sales', Appointment: 'BDC', Success: 'Service', Detail: 'Detailer', Delivery: 'Driver', Commerce: 'E-Commerce', Guest: 'Customer', Services: 'Service', Internet: 'BDC', Leasing: 'Sales', 'Pre Owned' => 'Used Car', HR: 'Human Resources', Management: 'Mgr', 'Owner President' => 'Owner', 'General Counsel' => 'Legal', 'Client Advisor' => 'Sales Rep', 'Team Leader' => 'Mgr', 'Delivery Coordinator' => 'Driver', Merchandiser: 'Rep', 'Call Center' => 'BDC', Controller: 'Fixed Operations', Warranty: 'Warranty Rep', Director: 'Dir', Marketing: 'Mktg', Supervisor: 'Supr', Administrator: 'Admin'}.stringify_keys
      job_desc = job_desc&.gsub(Regexp.union(swaps.keys), swaps)

      tops = %w(Asst Vice President General Executive)
      roles = %w(Used New Car Sales Accessories Accounting Accounts E-Commerce Administration Customer BDC Billing Body Brand Cashier CFO COO Collision Detailer Digital Finance Fleet Mktg Fixed Variable IT Inventory Operations Office Parts Payable Service Shop Technician Technology Title Warranty Human Resources Comptroller Legal Receptionist)
      roles += []
      levels = %w(Apprentice Clerk Dir Mgr Owner Principal Rep Secretary Supr Admin)

      title_arr = []
      tops.each { |top| title_arr << top if job_desc.include?(top) }
      roles.each { |role| title_arr << role if job_desc.include?(role) }
      levels.each { |level| title_arr << level if job_desc.include?(level) }
      job_title = title_arr.uniq.join(' ')

      job_title&.gsub!('Used Car Sales Mgr', 'Used Car Mgr')
      job_title&.gsub!('New Car Sales Mgr', 'New Car Mgr')
      job_title&.gsub!('Sales BDC', 'BDC')
      # job_title&.gsub!('Sales BDC Mgr', 'BDC Mgr')
      job_title&.gsub!('Sales Mktg Mgr', 'Mktg Mgr')
      job_title&.gsub!('Mktg Technician Dir', 'Mktg Dir')
      job_title&.gsub!('Used Car Sales Rep', 'Sales Rep')
      job_title&.gsub!('Sales Receptionist', 'Receptionist')
      job_title&.gsub!('Sales Rep Mgr', 'Sales Mgr')
      job_title&.gsub!('Sales Body', 'Body')
      job_title&.gsub!('Service Receptionist', 'Receptionist')
      job_title&.gsub!('Sales Finance Mgr', 'Sales Mgr')
      job_title&.gsub!('BDC Service', 'BDC')
      job_title&.gsub!('Accounting Clerk', 'Accounting')
      # job_title&.gsub!('', '')
      # job_title&.gsub!('', '')


      # if !job_title.present?
      #   job_titles = ['General Sales Manager', 'Internet Sales Manager', 'Sales Director', 'General Manager', 'Owner', 'President', 'Principal', 'Sales Manager', 'Sales Advisor', 'Service Manager', 'Service Advisor']
      #   job_titles.each { |job_title| return job_title if job_desc&.include?(job_title) }
      # end

      return job_title
    end
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
