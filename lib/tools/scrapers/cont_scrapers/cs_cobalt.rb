#CALL: ContScraper.new.start_cont_scraper

class CsCobalt
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    ## IMPORTANT: ----> ## Check validity of staff links.  Replae bad ones with:
      # /MeetOurDepartments
    cs_hsh_arr = []

    staffs = noko_page.css('.staffList .staff')
    staffs = noko_page.css("[@itemprop='employee']") if !staffs.any?
    staffs = noko_page.css('.wpb_row .vc_column_container') if !staffs.any?
    staffs = noko_page.css('.deck .card') if !staffs.any?

    cs_hsh_arr = @cs_helper.standard_scraper(staffs)
    binding.pry

    ## Difficult Below ###
    ## Name and Position on same line. - Dealer.com too.
    # "Trent Neely<br />General Manager" ## After running all, revisit to split by position.
    # http://www.arrowmitsubishi.com/staff/

    # for i in 0...staffs.count
    #   staff_hash = {}
    #   staff_str = staffs[i].inner_html
    #   staff_hash[:first_name] = noko_page.css('span[@itemprop="givenName"]')[i]&.text&.strip
    #   staff_hash[:last_name] = noko_page.css('span[@itemprop="familyName"]')[i]&.text&.strip
    #   staff_hash[:job_desc] = noko_page.css('[@itemprop="jobTitle"]')[i]&.text&.strip
    #
    #   regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
    #   matched_email = regex.match(staff_str)
    #   staff_hash[:email] = matched_email&.to_s
    #   staff_hash[:phone] = noko_page.css('span[@itemprop="telephone"]')[i]&.text&.strip
    #   staff_hash[:phone] = noko_page.css('.link [@itemprop="telephone"]')[i]&.text&.strip if !staff_hash[:phone].present?
    #   cs_hsh_arr << staff_hash
    # end

    return cs_hsh_arr
  end
end
