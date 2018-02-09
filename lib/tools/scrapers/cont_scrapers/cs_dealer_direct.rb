#CALL: ContScraper.new.start_cont_scraper

class CsDealerDirect

  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    cs_hsh_arr = []

    if noko_page.css('.staff-desc .staff-name').any?
      staff_count = noko_page.css('.staff-desc .staff-name').count

      for i in 0...staff_count
        staff_hash = {}
        staff_hash[:full_name] = noko_page.css('.staff-desc .staff-name')[i].text.strip
        staff_hash[:job_desc] = noko_page.css('.staff-desc .staff-title')[i] ? noko_page.css('.staff-desc .staff-title')[i].text.strip : ""
        staff_hash[:email] = noko_page.css('.staff-info .staff-email a')[i] ? noko_page.css('.staff-info .staff-email a')[i].text.strip : ""
        staff_hash[:phone] = noko_page.css('.staff-info .staff-tel')[i] ? noko_page.css('.staff-info .staff-tel')[i].text.strip : ""

        cs_hsh_arr << staff_hash
      end
    elsif noko_page.css('.staff-info').any?
      staffs = noko_page.css('.staff-info')
      cs_hsh_arr = @cs_helper.standard_scraper(staffs)
    end

    cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?

    if !cs_hsh_arr.any?
      staffs_arr = []
      staffs_arr << noko_page.css('.staff-body .row-fluid')
      staffs_arr << noko_page.css('.staff-list .listed-item')
      staffs_arr << noko_page.css('#staffList .staff')
      cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)
    end

    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr
  end
end
