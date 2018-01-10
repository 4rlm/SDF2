class CsStandardScraper
  def initialize
    @helper = CsHelper.new
  end

  def scrape_cont(html, url, indexer)
    staffs = html.css('.staffList .staff')
    staff_hash_array = staffs.any? ? @helper.standard_scraper(staffs) : []

    # @helper.print_result(indexer, url, staff_hash_array)
    @helper.prep_create_staffer(indexer, staff_hash_array)
  end
end
