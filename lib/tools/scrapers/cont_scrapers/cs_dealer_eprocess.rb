#CALL: ContScraper.new.start_cont_scraper

class CsDealerEprocess
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    cs_hsh_arr = []
    staffs = noko_page.css('.employee_wrap')
    staffs = noko_page.css('.employee_wrapper .employee_wrap_staff') if !staffs.any?
    cs_hsh_arr = @cs_helper.standard_scraper(staffs)
    return cs_hsh_arr
  end
end
