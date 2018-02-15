#CALL: ContScraper.new.start_cont_scraper

class CsFusionZone
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page, full_staff_link, act_obj)
    puts full_staff_link
    puts act_obj.temp_name
    cs_hsh_arr = []
    staffs_arr = []

    staffs_arr << noko_page.css(".staff-directory .Sales.column")
    cs_hsh_arr = @cs_helper.consolidate_cs_hsh_arr(staffs_arr)

    puts cs_hsh_arr.inspect
    cs_hsh_arr&.uniq!
    # binding.pry if !cs_hsh_arr.any?
    return cs_hsh_arr
  end
end
