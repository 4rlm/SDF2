module GenTally

  ### Notes on JSON QUERYING:
  # acts = Tally.last.acts
  # links = Tally.last.links
  # act_links = Tally.last.act_links

  # temp_names = acts['temp_name']
  # staff_links = links['staff_link']
  # cs_counts = act_links['cs_count']

  # staff_texts = Tally.last.links['staff_text'][0..20]
  # staff_links = Tally.last.links['staff_link'][0..40]
  # cs_counts = Tally.last.act_links['cs_count'][0..20]

  ## Tallies total counts of each uniq item from each of the models and cols below, then saves them to jsonb in Tally model.
  #CALL: GenTally.start_tally
  def self.start_tally
    mod_cols = [
    {mod: 'act', cols: ['act_name', 'url', 'temp_name', 'gp_id', 'gp_sts', 'url_sts', 'temp_sts', 'page_sts', 'cs_sts']},
    {mod: 'link', cols: ['staff_link', 'staff_text']},
    {mod: 'act_link', cols: ['link_sts', 'cs_count']},
    {mod: 'cont', cols: ['full_name', 'job_desc']}]
    ## IMPORTANT: added conts to schema.  Include above to get full_name and job_desc query - TO ADD TO BAN LIST!

    db_tallies = {}
    mod_cols.each do |mod_col|
      mod = mod_col[:mod]
      cols = mod_col[:cols]

      mod_tallies = {}
       cols.each do |col|
        mod_tallies.merge!(get_col_tally(mod, col))
      end

      db_tallies.merge!({"#{mod.pluralize}"=> mod_tallies})
    end

    tally = Tally.create!(db_tallies)
  end


  ## Helper method for start_tally method.
  def self.get_col_tally(mod_name, col)
    mod = mod_name.classify.constantize
    selected_fields = mod.select(col.to_sym).pluck(col.to_sym)
    field_groups_hsh = Hash[selected_fields.group_by {|x| x}.map {|k,v| [k,v.count]}]
    ranked_field_groups = field_groups_hsh.sort_by{|k,v| v}.reverse.to_h

    col_tallies_arr = ranked_field_groups.map do |field_group_arr|
      field_name = field_group_arr.first
      count = field_group_arr.last
      tallied_field_hsh = {"item"=> field_name, "count"=> count}
    end

    col_tallies_hsh = {"#{col}"=> col_tallies_arr}
    return col_tallies_hsh
  end


  # # SAVE: Works well, but not needed now.
  # def self.get_mod_cols(mod_name)
  #   mod = mod_name.classify.constantize
  #   cols = mod.column_names
  #   return {mod: mod_name, cols: cols}
  # end
  #


  ####### ORIGINAL BELOW - ABOVE REFACTORED VERSION. ######


  ## One time use to migrate from Act to Link, so Dash can be generated, so FindPage can be done - CHAIN REACTION!!
  #CALL: GenTally.migrate_to_link
  # def self.migrate_to_link
  #   acts = Act.where.not(staff_link: nil, staff_text: nil)
  #   acts.each do |act|
  #     link_obj = Link.find_or_create_by(staff_link: act.staff_link, staff_text: act.staff_text)
  #     act_link = act.links.where(id: link_obj).exists?
  #     act.links << link_obj if !act_link.present?
  #   end
  # end


  #CALL: GenTally.combo_tally
  # def self.combo_tally
  #   # prep_tally
  #   tally_links
  #   tally_texts
  # end

  ## prep_tally needs to be refactored, but method might not be necessary any more.
  #CALL: GenTally.prep_tally
  # def self.prep_tally

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
  # end

  #CALL: GenTally.tally_links
  # def self.tally_links
  #   Dash.where(category: 'staff_link').destroy_all
  #   reset_primary_ids
  #
  #   staff_links = Link.where.not(staff_link: nil).map { |link| link.staff_link }
  #   ranked_links = Hash[staff_links.group_by {|x| x}.map {|k,v| [k,v.count]}]
  #   sorted_links = ranked_links.sort_by{|k,v| v}.reverse.to_h
  #
  #   sorted_links.each do |link_arr|
  #     staff_link = link_arr.first
  #     count = link_arr.last
  #
  #     if count > 1
  #       link_hsh = {category: 'staff_link', focus: staff_link, count: count}
  #       tally_obj = Dash.find_by(category: 'staff_link', focus: staff_link)&.update(link_hsh)
  #       tally_obj = Dash.create(link_hsh) if !tally_obj.present?
  #     end
  #   end
  #
  #   ## Delete Bad links
  #   Dash.where(category: 'staff_link').where("focus like '%landing%'").destroy_all
  #   Dash.where(category: 'staff_link').where("focus like '%miscpage%'").destroy_all
  # end


  #CALL: GenTally.tally_texts
  # def self.tally_texts
  #   Dash.where(category: 'staff_text').destroy_all
  #   reset_primary_ids
  #
  #   staff_texts = Link.where.not(staff_text: nil).map { |link| link.staff_text }
  #   ranked_texts = Hash[staff_texts.group_by {|x| x}.map {|k,v| [k,v.count]}]
  #   sorted_texts = ranked_texts.sort_by{|k,v| v}.reverse.to_h
  #
  #   sorted_texts.each do |text_arr|
  #     staff_text = text_arr.first
  #     count = text_arr.last
  #
  #     if count > 1
  #       text_hsh = {category: 'staff_text', focus: staff_text, count: count}
  #       text_obj = Dash.find_by(category: 'staff_text', focus: staff_text)&.update(text_hsh)
  #       text_obj = Dash.create(text_hsh) if !text_obj.present?
  #     end
  #   end
  # end


  # def self.reset_primary_ids
  #   ActiveRecord::Base.connection.tables.each do |t|
  #     ActiveRecord::Base.connection.reset_pk_sequence!(t)
  #   end
  # end


end
