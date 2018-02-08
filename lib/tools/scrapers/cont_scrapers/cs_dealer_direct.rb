#CALL: ContScraper.new.start_cont_scraper

class CsDealerDirect
  # include FormatPhone

  def initialize
    @cs_helper = CsHelper.new
    # @as_manager = AsManager.new  ## Deprecated.  Should use Formatter or AsHelper.new
  end

  def scrape_cont(noko_page)
    cs_hsh_arr = []

    staff_array = []
    staffs = noko_page.css('.staff-body .row-fluid')
    staffs = noko_page.css('.staff-list .listed-item') if !staffs.any?
    staffs = noko_page.css('#staffList .staff') if !staffs.any?
    cs_hsh_arr = @cs_helper.standard_scraper(staffs)

    # staffs = noko_page.css('.staff-listing')
    # staffs = noko_page.css('.inner-container .staff-list')
    # staffs = noko_page.css('.staff-list')
    # staffs = noko_page.css('.staff-desc .staff-name') if !staffs.any?
    # staffs = noko_page.css('.staff-listing') if !staffs.any?
    # staffs = noko_page.css('.staff-container') if !staffs.any?
    # cs_hsh_arr = @cs_helper.standard_scraper(staffs) if !staffs.any?
    return cs_hsh_arr
  end
end
