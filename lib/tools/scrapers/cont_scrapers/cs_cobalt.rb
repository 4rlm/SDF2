class CsCobalt
  def initialize
    @helper = CsHelper.new
  end

  def scrape_cont(html, url, indexer)
    staffs = html.css("[@itemprop='employee']")
    staff_hash_array = []

    for i in 0...staffs.count
      staff_hash = {}
      staff_str = staffs[i].inner_html

      staff_hash[:fname] = html.css('span[@itemprop="givenName"]')[i].text.strip if html.css('span[@itemprop="givenName"]')[i]
      staff_hash[:lname] = html.css('span[@itemprop="familyName"]')[i].text.strip if html.css('span[@itemprop="familyName"]')[i]
      staff_hash[:job]   = html.css('[@itemprop="jobTitle"]')[i].text.strip   if html.css('[@itemprop="jobTitle"]')[i]

      regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
      matched_email = regex.match(staff_str)
      staff_hash[:email] = matched_email.to_s if matched_email

      # # Should find a common class within contact profile area.
      # [gh] phone is not listed for each employee.
      # staff_hash[:ph1] = html.css('span[@itemprop="telephone"]')[i].text.strip if html.css('span[@itemprop="telephone"]')[i]
      # staff_hash[:ph2] = html.css('.link [@itemprop="telephone"]')[i].text.strip if html.css('.link [@itemprop="telephone"]')[i]

      staff_hash_array << staff_hash
    end

    # @helper.print_result(indexer, url, staff_hash_array)
    @helper.prep_create_staffer(indexer, staff_hash_array)
  end
end
