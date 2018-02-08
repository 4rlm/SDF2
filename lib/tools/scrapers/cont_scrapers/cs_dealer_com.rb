#CALL: ContScraper.new.start_cont_scraper

class CsDealerCom
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    cs_hsh_arr = []

    staffs = noko_page.css('.staffList .staff')
    staffs = noko_page.css('#team-container .gridder-list') if !staffs.any?
    cs_hsh_arr = @cs_helper.standard_scraper(staffs)
    binding.pry

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
    return cs_hsh_arr
  end
end
