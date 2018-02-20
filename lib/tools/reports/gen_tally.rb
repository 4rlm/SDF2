module GenTally

  ## Tallies total scraped contacts per link/text combo.  Currently stored in Acts, but will later be moved to Link after fully migrated.  So will need to change Act to Link later.
  #CALL: GenTally.tally_link_cs_count
  def self.tally_link_cs_count
    ## Started setting up, but not finished.  Need to wait will scrape contacts uder new system because act cs_sts not reliable.
    # binding.pry
    # acts = Act.where(cs_sts: 'Valid').pluck(:id)
    # acts = Act.where(cs_sts: 'Valid').pluck(:id)
    # Cont.includes(:act).where(acts: {id: 1}, conts: {id: 1}).first
    # t.citext  :staff_link, null: false
    # t.citext  :staff_text, null: true
    # t.integer :cs_count, default: 0
  end

  ## One time use to migrate from Act to Link, so Tally can be generated, so FindPage can be done - CHAIN REACTION!!
  #CALL: GenTally.migrate_to_link
  def self.migrate_to_link
    acts = Act.where.not(staff_link: nil, staff_text: nil)
    acts.each do |act|
      link_obj = Link.find_or_create_by(staff_link: act.staff_link, staff_text: act.staff_text)
      act_link = act.links.where(id: link_obj).exists?
      act.links << link_obj if !act_link.present?
    end
  end


  #CALL: GenTally.combo_tally
  def self.combo_tally
    # prep_tally
    tally_links
    tally_texts
  end

  ## prep_tally needs to be refactored, but method might not be necessary any more.
  #CALL: GenTally.prep_tally
  def self.prep_tally

    ## Format Term Texts
    # terms = Term.where(sub_category: "staff_text").map do |term|
    #   staff_text = term.response_term.downcase&.gsub(/\W/,'')
    #   staff_text = staff_text.strip
    #   term.update(response_term: staff_text)
    # end

    ## Format Term Hrefs
    # terms = Term.where(sub_category: "staff_href").map do |term|
    #   staff_href = term.response_term.downcase
    #   staff_href = "/#{staff_href}" if staff_href[0] != "/"
    #   staff_href = staff_href.strip
    #   term.update(response_term: staff_href)
    # end

    ######## SPECIAL-RARE ABOVE ####

    # Downcase and Compacts staff_text
    # formatter = Formatter.new
    # acts = Link.where.not(staff_text: nil).map do |link|
    #   staff_text = link.staff_text.downcase&.gsub(/\W/,'')
    #   staff_link = formatter.format_link(link.url, link.staff_link)
    #   link.update(staff_text: staff_text, staff_link: staff_link)
    # end

    ## ACTS - Make Nil
    # make_nil_hsh = {cs_sts: nil, page_sts: nil, staff_text: nil, staff_link: nil }
    # Link.where(staff_link: nil).each {|link| link.update(make_nil_hsh)}
    # Link.where("staff_link LIKE '%card%'").each {|link| link.update(staff_link: '/meetourdepartments')}

    # text_strict_ban = %w(porsche)
    # text_strict_ban.each { |ban| Link.where(staff_text: ban).each {|link| link.update(make_nil_hsh)} }
    # Link.where(temp_name: "Cobalt", staff_text: "sales").each {|link| link.update(make_nil_hsh)}

    # link_strict_ban = %w(/about /about-us /about-us.htm /about.htm /about.html /dealership/about.htm /dealership/department.htm /dealership/news.htm /departments.aspx /index.htm /meetourdepartments /sales.aspx /#tab-sales)
    # link_strict_ban.each { |ban| Link.where(staff_link: ban).each {|link| link.update(make_nil_hsh)} }

    # light_ban = %w(404 appl approve body career center click collision contact customer demo direction discl drive employ espanol espaol finan get google guarantee habla history home hour inventory javascript job join lease legal lube mail map match multilingual offers oil open opportunit parts phone place price quick rating review sales_tab schedule search service special survey tel test text trade value vehicle video virtual websiteby welcome why)

    # light_ban.each do |ban|
      # acts = Link.where("staff_link LIKE '%#{ban}%'").each {|link| link.update(make_nil_hsh)}
      # acts = Link.where("staff_text LIKE '%#{ban}%'").each {|link| link.update(make_nil_hsh)}
    # end
  end

  #CALL: GenTally.tally_links
  def self.tally_links
    Tally.where(category: 'staff_link').destroy_all
    reset_primary_ids

    staff_links = Link.where.not(staff_link: nil).map { |link| link.staff_link }
    ranked_links = Hash[staff_links.group_by {|x| x}.map {|k,v| [k,v.count]}]
    sorted_links = ranked_links.sort_by{|k,v| v}.reverse.to_h

    sorted_links.each do |link_arr|
      staff_link = link_arr.first
      count = link_arr.last

      if count > 1
        link_hsh = {category: 'staff_link', focus: staff_link, count: count}
        tally_obj = Tally.find_by(category: 'staff_link', focus: staff_link)&.update(link_hsh)
        tally_obj = Tally.create(link_hsh) if !tally_obj.present?
      end
    end

    ## Delete Bad links
    Tally.where(category: 'staff_link').where("focus like '%landing%'").destroy_all
    Tally.where(category: 'staff_link').where("focus like '%miscpage%'").destroy_all
  end


  #CALL: GenTally.tally_texts
  def self.tally_texts
    Tally.where(category: 'staff_text').destroy_all
    reset_primary_ids

    staff_texts = Link.where.not(staff_text: nil).map { |link| link.staff_text }
    ranked_texts = Hash[staff_texts.group_by {|x| x}.map {|k,v| [k,v.count]}]
    sorted_texts = ranked_texts.sort_by{|k,v| v}.reverse.to_h

    sorted_texts.each do |text_arr|
      staff_text = text_arr.first
      count = text_arr.last

      if count > 1
        text_hsh = {category: 'staff_text', focus: staff_text, count: count}
        text_obj = Tally.find_by(category: 'staff_text', focus: staff_text)&.update(text_hsh)
        text_obj = Tally.create(text_hsh) if !text_obj.present?
      end
    end
  end




  #CALL: GenTally.tally_templates
  def self.tally_templates
    templates = Link.where.not(temp_name: nil).map { |link| link.temp_name }
    ranked_temps = Hash[templates.group_by {|x| x}.map {|k,v| [k,v.count]}]
    sorted_temps = ranked_temps.sort_by{|k,v| v}.reverse.to_h

    sorted_temps.each do |temp_arr|
      temp_name = temp_arr.first
      count = temp_arr.last

      if count > 3
        temp_hsh = {temp_name: temp_name, count: count}
        puts temp_hsh
      end

    end
  end


  def self.reset_primary_ids
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end


end
