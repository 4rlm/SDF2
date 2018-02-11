module Reporter


  # CALL: Reporter.db_totals_report
  def self.db_totals_report
    db_totals = CsvTool.new.get_db_table_list.sort.map do |e|
      [e.pluralize, e.constantize.all.count]
    end.to_h

    puts "\n\n#{'='*40}\n=== Report: DB Totals ==="
    puts db_totals.to_yaml
  end



  ## IMPORTANT!
  # conts = Act.where("staff_link LIKE '%card%'").each { |cont| cont.update(staff_link: '/MeetOurDepartments') }

  # acts = Act.where.not(staff_link: nil).count

  #CALL: Reporter.get_both_tallies
  def self.get_both_tallies
    prep_tally
    tally_links
    tally_texts
  end

  #CALL: Reporter.prep_tally
  def self.prep_tally

    # Downcase and Compacts staff_text
    acts = Act.where.not(staff_text: nil).map do |act|
      staff_text = act.staff_text.downcase&.gsub(/\W/,'')
      act.update(staff_text: staff_text)
    end

    ## DELETE ACTS
    make_nil_hsh = {page_sts: 'Invalid', staff_text: nil, staff_link: nil }
    Act.where(staff_link: "/#").each {|act| act.update(make_nil_hsh)}
    Act.where(page_sts: 'Valid', staff_link: nil ).each {|act| act.update(make_nil_hsh)}

    banned = %w(404 appl approve body career center click collision contact coupon credit customer demo direction discl drive employ espaol fact finan get google guarantee habla history home hour inventory javascript job join lease legal locat lube mail map match offers oil open opportunit part phone place pre price quick rating review schedule search service special story survey tel test text tour trade value vehicle video virtual website welcome what why)

    banned.each do |ban|
      acts = Act.where("staff_link LIKE '%#{ban}%'").each {|act| act.update(make_nil_hsh)}
      acts = Act.where("staff_text LIKE '%#{ban}%'").each {|act| act.update(make_nil_hsh)}
    end
  end

  #CALL: Reporter.tally_links
  def self.tally_links
    Link.destroy_all
    reset_primary_ids

    staff_links = Act.where.not(staff_link: nil).map { |act| act.staff_link }
    ranked_links = Hash[staff_links.group_by {|x| x}.map {|k,v| [k,v.count]}]
    sorted_links = ranked_links.sort_by{|k,v| v}.reverse.to_h

    sorted_links.each do |link_arr|
      link_name = link_arr.first
      count = link_arr.last

      if count > 1
        link_hsh = {staff_link: link_name, count: count}
        link_obj = Link.find_by(staff_link: link_name)&.update(link_hsh)
        link_obj = Link.create(link_hsh) if !link_obj.present?
      end
    end

    ## DELETE LINKS
    Link.where("staff_link like '%landing%'").destroy_all
    Link.where("staff_link like '%miscpage%'").destroy_all
    Link.where(staff_link: nil).destroy_all
  end


  #CALL: Reporter.tally_texts
  def self.tally_texts
    Text.destroy_all
    reset_primary_ids

    staff_texts = Act.where.not(staff_text: nil).map { |act| act.staff_text }
    ranked_texts = Hash[staff_texts.group_by {|x| x}.map {|k,v| [k,v.count]}]
    sorted_texts = ranked_texts.sort_by{|k,v| v}.reverse.to_h

    sorted_texts.each do |text_arr|
      text_name = text_arr.first
      count = text_arr.last

      if count > 1
        text_hsh = {staff_text: text_name, count: count}
        text_obj = Text.find_by(staff_text: text_name)&.update(text_hsh)
        text_obj = Text.create(text_hsh) if !text_obj.present?
      end
    end

    ## DELETE TEXTS
    Text.where(staff_text: nil).destroy_all
  end

  def self.reset_primary_ids
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end


end
