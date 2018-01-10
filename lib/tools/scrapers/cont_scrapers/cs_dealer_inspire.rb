class CsDealerInspire
  def initialize
    @helper = CsHelper.new
  end

  def scrape_cont(html, url, indexer)
    if html.css('.staff-bio h3')
      staff_count = html.css('.staff-bio h3').count
      staff_hash_array = []

      for i in 0...staff_count
        staff_hash = {}
        # staff_hash[:full_name] = html.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-name")[i].value
        # staff_hash[:job] = html.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-title") ? html.xpath("//a[starts-with(@href, 'mailto:')]/@data-staff-title")[i].value : ""
        staff_hash[:full_name] = html.css('.staff-bio h3')[i] ? html.css('.staff-bio h3')[i].text.strip : ""
        staff_hash[:job] = html.css('.staff-bio h4')[i] ? html.css('.staff-bio h4')[i].text.strip : ""

        staff_hash[:email] = html.css('.staff-email-button')[i] ? html.css('.staff-email-button')[i].attributes["href"].text.gsub(/^mailto:/, '') : ""

        # staff_hash[:email] = html.css('.staff-email-button')[i].attributes["href"] ? html.css('.staff-email-button')[i].attributes["href"].text : ""

        staff_hash[:phone] = html.css('.staffphone')[i] ? html.css('.staffphone')[i].text.strip : ""

        staff_hash_array << staff_hash
      end
    end

    # @helper.print_result(indexer, url, staff_hash_array)
    @helper.prep_create_staffer(indexer, staff_hash_array)
  end
end
