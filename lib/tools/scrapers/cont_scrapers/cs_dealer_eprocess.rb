class CsDealerEprocess
  def initialize
    @helper = CsHelper.new
  end

  def scrape_cont(html, url, indexer)
    staffs = html.css(".employee_wrap")
    staff_hash_array = []

    staffs.each do |staff|
      staff_hash = {}
      # Get name, job, phone
      info_ori = staff.text.split("\n").map {|el| el.delete("\t") }
      infos = info_ori.delete_if {|el| el.blank?}

      names = html.css(".employee_name").text
      jobs = html.css(".employee_title").text

      infos.each do |info|
        num_reg = Regexp.new("[0-9]+")
        if jobs.include?(info)
          staff_hash[:job] = info
        elsif names.include?(info)
          staff_hash[:full_name] = info
        elsif num_reg.match(info) && info.length < 17
          staff_hash[:phone] = info
        end
      end

      # Get email
      data = staff.inner_html
      regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
      email_reg = regex.match(data)
      staff_hash[:email] = email_reg.to_s if email_reg

      staff_hash_array << staff_hash
    end

    # @helper.print_result(indexer, url, staff_hash_array)
    @helper.prep_create_staffer(indexer, staff_hash_array)
  end
end
