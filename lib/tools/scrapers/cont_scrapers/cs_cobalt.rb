#CALL: ContScraper.new.start_cont_scraper

class CsCobalt
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)

    staffs = noko_page.css("[@itemprop='employee']")
    cs_hsh_arr = []

    for i in 0...staffs.count
      staff_hash = {}
      staff_str = staffs[i].inner_html

      staff_hash[:first_name] = noko_page.css('span[@itemprop="givenName"]')[i].text.strip if noko_page.css('span[@itemprop="givenName"]')[i]
      staff_hash[:last_name] = noko_page.css('span[@itemprop="familyName"]')[i].text.strip if noko_page.css('span[@itemprop="familyName"]')[i]
      staff_hash[:job_desc]   = noko_page.css('[@itemprop="jobTitle"]')[i].text.strip   if noko_page.css('[@itemprop="jobTitle"]')[i]

      regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
      matched_email = regex.match(staff_str)
      staff_hash[:email] = matched_email.to_s if matched_email

      # # Should find a common class within contact profile area.
      # [gh] phone is not listed for each employee.
      # staff_hash[:ph1] = noko_page.css('span[@itemprop="telephone"]')[i].text.strip if noko_page.css('span[@itemprop="telephone"]')[i]
      # staff_hash[:ph2] = noko_page.css('.link [@itemprop="telephone"]')[i].text.strip if noko_page.css('.link [@itemprop="telephone"]')[i]

      cs_hsh_arr << staff_hash
    end

    cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?
    puts cs_hsh_arr

    if !cs_hsh_arr.any?
      staffs_arr = []
      staffs_arr << noko_page.css('.staffList .staff')
      staffs_arr << noko_page.css(".deck [@itemprop='employee']")
      staffs_arr << noko_page.css("[@itemprop='employee']")
      staffs_arr << noko_page.css('.wpb_row .vc_column_container')
      staffs_arr << noko_page.css('.wpb_row .desc_wrapper')
      staffs_arr << noko_page.css('.deck .card')
      staffs_arr << noko_page.css('#af-static .af-staff-member')

      cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)
    end

    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr


    #############################
    ## IMPORTANT: ----> ## Check validity of staff links.  Replace bad ones with:
      # /MeetOurDepartments

    ## Difficult Below ###
    ## Name and Position on same line. - Dealer.com too.
    # "Trent Neely<br />General Manager" ## After running all, revisit to split by position.
    # http://www.arrowmitsubishi.com/staff/
  end
end
