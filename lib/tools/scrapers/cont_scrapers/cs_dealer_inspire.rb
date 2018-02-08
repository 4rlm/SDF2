#CALL: ContScraper.new.start_cont_scraper

class CsDealerInspire
  def initialize
    @cs_helper = CsHelper.new
  end

  def scrape_cont(noko_page)
    cs_hsh_arr = []
    # staffs = noko_page.css('.staff-container .staff-item')
    staffs = noko_page.css('.staff .staff-item')
    staffs = noko_page.css('.staff-bio h3') if !staffs.any?

    cs_hsh_arr = @cs_helper.standard_scraper(staffs)
    return cs_hsh_arr
  end

  ##### Original ###
  # def scrape_cont(noko_page)
  #   binding.pry
  #   if noko_page.css('.staff-bio h3')
  #     staff_count = noko_page.css('.staff-bio h3').count
  #     cs_hsh_arr = []
  #
  #     for i in 0...staff_count
  #       staff_hash = {}
  #       # staff_hash[:full_name] = noko_page.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-name")[i].value
  #       # staff_hash[:job] = noko_page.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-title") ? noko_page.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-title")[i].value : ""
  #       staff_hash[:full_name] = noko_page.css('.staff-bio h3')[i] ? noko_page.css('.staff-bio h3')[i].text.strip : ""
  #       staff_hash[:job] = noko_page.css('.staff-bio h4')[i] ? noko_page.css('.staff-bio h4')[i].text.strip : ""
  #
  #       staff_hash[:email] = noko_page.css('.staff-email-button')[i] ? noko_page.css('.staff-email-button')[i].attributes["href"].text.gsub(/^mailto:/, '') : ""
  #
  #       # staff_hash[:email] = noko_page.css('.staff-email-button')[i].attributes["href"] ? noko_page.css('.staff-email-button')[i].attributes["href"].text : ""
  #
  #       staff_hash[:phone] = noko_page.css('.staffphone')[i] ? noko_page.css('.staffphone')[i].text.strip : ""
  #
  #       cs_hsh_arr << staff_hash
  #     end
  #   end
  #
  #   return cs_hsh_arr
  # end
end
