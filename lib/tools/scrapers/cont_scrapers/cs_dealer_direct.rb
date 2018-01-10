class CsDealerDirect
  # include PhoneFormatter

  def initialize
    @helper = CsHelper.new
    # @as_manager = AsManager.new  ## Deprecated.  Should use Formatter or AsHelper.new
  end

  def scrape_cont(html, url, indexer)
    staff_hash_array = []

    if html.css('.staff-desc .staff-name').any?
      staff_count = html.css('.staff-desc .staff-name').count

      for i in 0...staff_count
        staff_hash = {}
        staff_hash[:full_name] = html.css('.staff-desc .staff-name')[i].text.strip
        staff_hash[:job] = html.css('.staff-desc .staff-title')[i] ? html.css('.staff-desc .staff-title')[i].text.strip : ""
        staff_hash[:email] = html.css('.staff-info .staff-email a')[i] ? html.css('.staff-info .staff-email a')[i].text.strip : ""
        staff_hash[:phone] = html.css('.staff-info .staff-tel')[i] ? html.css('.staff-info .staff-tel')[i].text.strip : ""

        staff_hash_array << staff_hash
      end
    elsif html.css('.staff-info').any?
      staffs = html.css('.staff-info')

      staffs.each do |staff|
        staff_hash = {}
        # Get name, job, phone
        info_ori = staff.text.split("\n").map {|el| el.delete("\t") }
        infos = info_ori.delete_if {|el| el.blank?}

        infos.each do |info|
          name_bool = @helper.name_detector(info)
          job_bool = @helper.job_detector(info)
          phone_bool = @helper.phone_detector(info)

          if job_bool
            staff_hash[:job] = info
          elsif name_bool && !job_bool && !phone_bool
            staff_hash[:full_name] = info
          elsif phone_bool
            staff_hash[:phone] = phone_formatter(info) #=> via PhoneFormatter
          end
        end

        # Get email
        data = staff.inner_html
        regex = Regexp.new("[a-z]+[@][a-z]+[.][a-z]+")
        email_reg = regex.match(data)
        staff_hash[:email] = email_reg.to_s if email_reg

        staff_hash_array << staff_hash
      end
    end

    # @helper.print_result(indexer, url, staff_hash_array)
    @helper.prep_create_staffer(indexer, staff_hash_array)
  end
end
