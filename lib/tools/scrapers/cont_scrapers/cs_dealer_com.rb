#CALL: ContScraper.new.start_cont_scraper

class CsDealerCom
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    staffs_arr = []

    staffs_arr << noko_page.css('.staffList .staff')
    staffs_arr << noko_page.css('#team-container .gridder-list')
    staffs_arr << noko_page.css('.tight-0 .staff-rightside')
    staffs_arr << noko_page.css('#reviewsSection .employee-details-wrapper')
    staffs_arr << noko_page.css('.yui3-u-2-3 .wysiwyg-table')

    cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)

    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr

    ## Difficult Below ###
    ## When no contacts, check link: /meet-the-staff.htm, like below example.
    # https://www.birminghambmw.com/meet-the-staff.htm
    # https://www.birminghambmw.com/dealership/staff.htm

    ## Difficult Below ###
    ## Name and Position on same line. - Cobalt too.
    # "Trent Neely<br />General Manager" ## After running all, revisit to split by position.
    # http://www.bobbyrahalmotorcar.com/dealership/staff.htm

    ## Difficult Below ###
    ## Can't find correct class or id to grab anything.
    # http://www.superiorkia.com/meet-our-team.htm
    # staffs = noko_page.css('#empdiv .employeelistingblock') if !staffs.any?
    # staffs = noko_page.css('div.employeelistingblock') if !staffs.any?
    # staffs = noko_page.css('#sales')
  end
end
