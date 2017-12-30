module WebFormatter
  ## IMPORTANT: web_formatter_orig.rb is combining everything, but needs to strictly be FORMATTER!!, which can be used generally by other unrelated processes.  Will take RAW DATA, NOT OBJECTS.  AND WILL RETURN FORMATTED DATA TO BE USED WITH MIGRATOR.

  ## Migrator should send raw url here, then receive formatted url before sending it to be used in format_link_text.

  #CALL: WebFormatter.format_url(url)
  def self.format_url(url)
    # if url.present?
      url = url.downcase.strip
      url = url[0..-2] if url[-1] == '/'
      return url
    # end
  end


  #CALL: WebFormatter.format_link(url, link)
  def self.format_link(url, link)
    url = strip_down_url(url)
    link = strip_down_url(link)
    link.slice!(url)

    if link&.include?(url) && !link.include?('@')# sometimes url is listed twice in link.
      link.slice!(url)
      link = link.gsub("///", '')
    end

    link = remove_invalid_links(link) if link.present?
    link.insert(0, '/') if (link.present? && link[0] != '/')  # link&.send('[]', 0).send('!=')
    link = link[0..-2] if (link.present? && link[-1] == '/')
    return link
  end


  # Both Link and URL use this to make them equal for comparison, but only Link's changes save.  Not url.
  #CALL: WebFormatter.strip_down_url(url_4)
  def self.strip_down_url(url)
    url = url.downcase.strip
    url = url.gsub('www.', '')
    url = url.split('://')
    url = url[-1]
    return url
  end


  #CALL: WebFormatter.remove_invalid_links(link)
  def self.remove_invalid_links(link)
    invalid_link_list = [':', '.co', '.net', '.gov', '.biz', '.edu', '(', '[', '@', '//', 'bye', 'hello', 'home', 'hours', 'form', 'regist', 'http', 'mail', 'mailto', 'none', 'test', 'twitter', 'www', 'yelp', 'login', 'feed', 'offer', 'service', 'graphic', 'phone', 'cont', 'event', 'youth', 'school', 'info', '%', '+', 'tire', 'business', 'review', 'inventory', 'download', '*', 'afri', 'drop', 'item', '.jpg', 'shop', 'face', 'book', 'insta', 'ticket', 'cheap', 'gas', 'priva', 'mobile', 'site', 'call', 'part', 'feature', 'hospi', 'financ', 'fleet', 'policy', 'watch', 'tv', 'rate', 'hour', 'collis', 'schedul', 'find', '*', 'anounc', 'distrib', 'click', 'museu', 'movie', 'music', 'news', 'join', 'buy', 'cash', 'generat', 'pump']

    make_link_nil = invalid_link_list.any? {|word| link&.include?(word) }  ## .try and &.
    link = nil if (make_link_nil || link == "/")
    link = nil if link&.length&.> 60    ## .try and &.
    return link
  end


  def self.remove_invalid_texts(text)
    text = nil if text&.length&.> 35  ## .try and &.
    invalid_text = Regexp.new(/[0-9]/)
    text = nil if invalid_text&.match(text) ## .try and &.
    text = text&.downcase   ## .try and &.
    text = text&.strip   ## .try and &.

    invalid_text_list = ['none', '@', '.com', 'after', 'service', 'check', 'approved', 'deal', '?', 'inventory', 'truck', 'login', 'saving', 'event', 'holiday', 'light', 'shop', 'info', 'face', 'book', 'twitter', 'insta', 'ticket', 'cheap', 'gas', 'priva', 'mobile', 'site', 'call', 'mail', 'cont', 'phone', 'part', 'feature', 'hospi', 'financ', 'fleet', 'policy', 'watch', 'tv', 'rate', 'hour', 'collis', 'schedul', 'find', 'tire', 'business', 'review', 'download', '*', 'afri', 'feed', 'anounc', 'distrib', 'click', 'charit', 'contrib', 'here', 'form', 'quote', 'quick', 'oil', 'regist', 'buy', 'pay', 'later', 'now', 'speci', 'commerc', 'sign', 'youth', 'blog', 'transla', 'golf', 'today', 'apply', 'employ', 'career', 'care', 'travel', '.jpg', 'museu', 'movie', 'music', 'news', 'join', 'buy', 'cash', 'generat', 'pump']

    make_text_nil = invalid_text_list.any? {|word| text&.include?(word) }  ## .try and &.
    text = nil if make_text_nil
    return text
  end













  ## Should get pre-formatted url from Migrator.  Assumes url is already formatted.
  def format_link_or_text(url)
    return url
  end


  #### ALL OF BELOW NEEDS TO BE SEPARATED OUT OR DELETED  ####


  def migrate_web_and_links(web_obj)
  # Call: Formatter.new.format_webs

  # Call: WebFormatter.migrate_web_and_links(web_obj)

  # IMPORTANT: MIGHT NEED TO ADAPT AND INTEGRATE THIS WITH Migrator.new.migrate_uni_acts via lib/tools/migrators/uni_migrator.rb
  ## MIGHT NOT NEED LOGIC BELOW, BECAUSE STAFF_PAGE AND LOCATIONS_PAGE COLUMNS WILL BE REMOVED. ##
  ## CONSIDER ADAPTING THIS FOR UniActs MIGRATOR TO PARSE UP WEB URL FIELDS INTO ASSOCIATIONS.
  ## 2 conditionals below format staff and locations page, then find or create Link object in links table, then save associations to web_obj.  Then remove staff and locations page link from Web object.

    url = format_url(web_obj.url)
    staff_link = web_obj.staff_page
    locations_link = web_obj.locations_page

    updated_web_hsh = {}
    updated_web_hsh = {url: url, staff_page: nil, locations_page: nil}

    staff_link = format_link(url, staff_link) if staff_link
    staff_link_obj = save_link(web_obj, staff_link, 'staff') if staff_link

    locations_link = format_link(url, locations_link) if locations_link
    locations_link_obj = save_link(web_obj, locations_link, 'locations') if locations_link

    web_obj.update_attributes(updated_web_hsh)
  end



  #### ORIGINAL BELOW, DELETE AFTER TESTING BOTTOM REPLACEMENT ###

  def save_link(web_obj, link, link_type)
    link_obj = Link.find_by(link: link)
    link_obj = Link.create(link: link, link_type: link_type) if !link_obj
    ## Need to: Return link_obj, then create new method for below.
    web_obj.links << link_obj if !web_obj.links.include?(link_obj)
  end

  #### TESTING BELOW ###

  ## CONSIDER USING (similar to): save_complex_obj, OR save_simple_obj via Migrator Class.

  ### BELOW REPLACES save_link ABOVE ###
  def save_link_or_text(web_obj, link, link_type) # Saves Link OR Text.
    link_obj = Link.find_by(link: link)
    link_obj = Link.create(link: link, link_type: link_type) if !link_obj
    ## Need to: Return link_obj, then create new method for below.
    web_obj.links << link_obj if !web_obj.links.include?(link_obj)
  end


  #### TESTING ABOVE ###




end
