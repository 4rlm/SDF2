
module WebFormatter


  def migrate_web_and_links(web_obj)
  # Call: AboutFormatter.new.format_webs

  # Call: WebFormatter.migrate_web_and_links(web_obj)

  # IMPORTANT: MIGHT NEED TO ADAPT AND INTEGRATE THIS WITH AboutMigrator.new.migrate_uni_accounts via lib/tools/migrators/uni_migrator.rb
  ## MIGHT NOT NEED LOGIC BELOW, BECAUSE STAFF_PAGE AND LOCATIONS_PAGE COLUMNS WILL BE REMOVED. ##
  ## CONSIDER ADAPTING THIS FOR UniAccounts MIGRATOR TO PARSE UP WEB URL FIELDS INTO ASSOCIATIONS.
  ## 2 conditionals below format staff and locations page, then find or create Link object in links table, then save associations to web_obj.  Then remove staff and locations page link from Web object.

    url = format_url(web_obj.url)
    staff_link = web_obj.staff_page
    locations_link = web_obj.locations_page

    updated_web_hash = {}
    updated_web_hash = {url: url, staff_page: nil, locations_page: nil}

    staff_link = format_link(url, staff_link) if staff_link
    staff_link_obj = save_link(web_obj, staff_link, 'staff') if staff_link

    locations_link = format_link(url, locations_link) if locations_link
    locations_link_obj = save_link(web_obj, locations_link, 'locations') if locations_link

    web_obj.update_attributes(updated_web_hash)
  end


  def format_url(url)
    url = url.downcase.strip
    url = url[0..-2] if url[-1] == '/'
    return url
  end


  def format_link(url, link)
    link = link.downcase.strip
    link.slice!(url)
    link = remove_invalid_links(link)
    return link
  end


  def remove_invalid_links(link)
    invalid_link_list = [':', '.com', '(', '[', '@', '//', '#', 'bye', 'hello', 'home', 'http', 'mail', 'mailto', 'none', 'test', 'twitter', 'www', 'yelp']
    make_link_nil = invalid_link_list.any? {|word| link.include?(word) }
    link.insert(0, '/') if link[0] != '/'
    link = link[0..-2] if link[-1] == '/'
    link = nil if (make_link_nil || link == "/")
    return link
  end


  def save_link(web_obj, link, link_type)
    link_obj = Link.find_by(link: link)
    link_obj = Link.create(link: link, link_type: link_type) if !link_obj
    web_obj.links << link_obj if !web_obj.links.include?(link_obj)
  end



end
