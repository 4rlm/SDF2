class CsDealeron
  def initialize
    @helper = CsHelper.new
  end

  def scrape_cont(html, url, indexer)
    staff_hash_array = []

    if html.css('.staff-row .staff-title')
      staff_count = html.css('.staff-row .staff-title').count
      puts "staff_count: #{staff_count}"
      staffs = html.css(".staff-contact")

      for i in 0...staff_count
        staff_hash = {}
        staff_hash[:full_name] = html.css('.staff-row .staff-title')[i].text.strip
        staff_hash[:job] = html.css('.staff-desc')[i] ? html.css('.staff-desc')[i].text.strip : ""

        ph_email_hash = @helper.ph_email_scraper(staffs[i])
        staff_hash[:phone] = ph_email_hash[:phone]
        staff_hash[:email] = @helper.email_cleaner(ph_email_hash[:email])

        staff_hash_array << staff_hash
      end
    end

    # @helper.print_result(indexer, url, staff_hash_array)
    @helper.prep_create_staffer(indexer, staff_hash_array)
  end
end
