#CALL: ContScraper.new.start_cont_scraper

class CsDealeron
  def initialize
    @cs_helper = CsHelper.new
  end


  def scrape_cont(noko_page)
    cs_hsh_arr = []

    if noko_page.css('.staff-row .staff-title')
      staff_count = noko_page.css('.staff-row .staff-title').count
      puts "staff_count: #{staff_count}"
      staffs = noko_page.css(".staff-contact")

      for i in 0...staff_count
        staff_hash = {}
        staff_hash[:full_name] = noko_page.css('.staff-row .staff-title')[i].text.strip
        staff_hash[:job_desc] = noko_page.css('.staff-desc')[i] ? noko_page.css('.staff-desc')[i].text.strip : ""

        ph_email_hash = ph_email_scraper(staffs[i])
        # staff_hash[:phone] = ph_email_hash[:phone]
        staff_hash[:phone] = Formatter.new.validate_phone(ph_email_hash[:phone])
        staff_hash[:email] = @cs_helper.email_cleaner(ph_email_hash[:email])
        cs_hsh_arr << staff_hash
      end
    end

    if !cs_hsh_arr.any?
      staffs_arr = []
      staffs_arr << noko_page.css('.staff-row .staff-title')
      staffs_arr << noko_page.css('.staff-contact')
      staffs_arr << noko_page.css('#staffList .staff')
      staffs_arr << noko_page.css('#myTabContent .container_div')
      staffs_arr << noko_page.css('.teamSection .teamMember')

      # staffs_arr << noko_page.css('#content-main .employee_info') ## Close, but needs work.
      cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)
    end

    # binding.pry if !cs_hsh_arr.any?

    puts cs_hsh_arr
    return cs_hsh_arr
  end


  def ph_email_scraper(staff)
    if staff&.children&.any?
      info = {}
      value_1 = staff&.children[1]&.attributes["href"]&.value if staff.children[1]&.any?
      value_3 = staff&.children[3]&.attributes["href"]&.value if staff.children[3]&.any?

      info[:phone] = value_1 if value_1&.include?("tel:")
      info[:email] = value_1 if value_1&.include?("mailto:")
      info[:phone] = value_3 if value_3&.include?("tel:")
      info[:email] = value_3 if value_3&.include?("mailto:")
      return info
    end
  end


end
