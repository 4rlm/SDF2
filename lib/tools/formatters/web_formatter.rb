
module WebFormatter

  def parse_staff_location_pages(web_obj)
    # Call: WebFormatter.parse_staff_location_pages(web_obj)
    # Call: AboutFormatter.new.format_webs

    url = web_obj.url.try(:downcase)
    staff_page = web_obj.staff_page.try(:downcase)
    locations_page = web_obj.locations_page.try(:downcase)
    updated_pages = {}

    if url[-1] == '/'
      url = url[0..-2]
      updated_pages[:url] = url
    end

    if staff_page
      staff_page.slice!(url)
      staff_page = remove_invalid_pages(staff_page)
      updated_pages[:staff_page] = staff_page
    end

    if locations_page
      locations_page.slice!(url)
      locations_page = remove_invalid_pages(locations_page)
      updated_pages[:locations_page] = locations_page
    end

    web_obj.update_attributes(updated_pages)
  end


  def remove_invalid_pages(page)
  # Call: AboutFormatter.new.format_webs
    invalid_page_list = ['test', 'hello', 'bye', '(', 'none', '[', 'twitter', 'www', 'http', '#', 'mailto', ':', 'mail', '@', 'home']
    make_page_nil = invalid_page_list.any? {|word| page.include?(word) }
    page = nil if (make_page_nil || page == "/")
    return page
  end





end
