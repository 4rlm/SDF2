
module WebFormatter

  def parse_staff_location_pages(web_obj)
    # Call: WebFormatter.parse_staff_location_pages(web_obj)
    # Call: AboutFormatter.new.format_webs

    url = web_obj.url
    staff_page = web_obj.staff_page
    locations_page = web_obj.locations_page
    updated_pages = {}

    if url[-1] == '/'
      url = url[0..-2]
      updated_pages[:url] = url
    end

    if staff_page
      staff_page.slice!(url)
      updated_pages[:staff_page] = staff_page
    end

    if locations_page
      locations_page.slice!(url)
      updated_pages[:locations_page] = locations_page
    end

    web_obj.update_attributes(updated_pages)
  end


end
