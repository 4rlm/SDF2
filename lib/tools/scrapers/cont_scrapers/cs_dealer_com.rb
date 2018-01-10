class CsDealerCom
  def initialize
    @helper = CsHelper.new
  end

  def scrape_cont(html, url, indexer)
    # ===== OLD VER. =====
    # if html.css('#staffList .vcard .fn')
    #     staff_count = html.css('#staffList .vcard .fn').count
    #     staff_hash_array = []
    #
    #     for i in 0...staff_count
    #         staff_hash = {}
    #         staff_hash[:full_name] = html.css('#staffList .vcard .fn')[i].text.strip
    #         staff_hash[:job] = html.css('#staffList .vcard .title') ? html.css('#staffList .vcard .title')[i].text.strip : ""
    #         staff_hash[:email] = html.css('#staffList .vcard .email') ? html.css('#staffList .vcard .email')[i].text.strip : ""
    #         staff_hash[:phone] = html.css('#staffList .vcard .phone') ? html.css('#staffList .vcard .phone')[i].text.strip : ""
    #
    #         staff_hash_array << staff_hash
    #     end
    # end

    staffs = html.css('.staffList .staff')
    staff_hash_array = staffs.any? ? @helper.standard_scraper(staffs) : []


    # @helper.print_result(indexer, url, staff_hash_array)
    @helper.prep_create_staffer(indexer, staff_hash_array)
  end
end
