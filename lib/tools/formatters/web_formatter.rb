
module WebFormatter

  def parse_staff_location_links(id)
  # Call: WebFormatter.parse_staff_location_links(web_obj)
  # Call: AboutFormatter.new.format_webs
    web_obj = Web.find(id)

    url = web_obj.url.try(:downcase)
    staff_link = web_obj.staff_page.try(:downcase)
    locations_link = web_obj.locations_page.try(:downcase)
    updated_pages = {}

    if url[-1] == '/'
      url = url[0..-2]
      updated_pages[:url] = url
    end

    if staff_link
      staff_link.slice!(url)
      staff_link = remove_invalid_links(staff_link)
      updated_pages[:staff_page] = staff_link
      save_link(web_obj, staff_link, 'staff')
    end

    if locations_link
      locations_link.slice!(url)
      locations_link = remove_invalid_links(locations_link)
      updated_pages[:locations_page] = locations_link
      save_link(web_obj, locations_link, 'locations')
    end

    !updated_pages.blank? ? web_obj.update_attributes(updated_pages) : web_obj.touch
    # !updated_pages.blank? ? web_obj.update_attributes(updated_pages) : web_obj.try(:touch)
  end


  def save_link(web_obj, link, link_type)
    link_obj = Link.find_by(link: link)
    link_obj = Link.create(link: link, link_type: link_type) if !link_obj
    web_obj.links << link_obj if !web_obj.links.include?(link_obj)
  end


  def remove_invalid_links(link)
    invalid_link_list = ['test', 'hello', 'bye', '(', 'none', '[', 'twitter', 'www', 'http', '#', 'mailto', ':', 'mail', '@', 'home']
    make_link_nil = invalid_link_list.any? {|word| link.include?(word) }
    link.insert(0, '/') if link[0] != '/'
    link = nil if (make_link_nil || link == "/")
    return link
  end


end
