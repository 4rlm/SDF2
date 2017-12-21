module Reporter


  # CALL: Reporter.db_totals_report
  def self.db_totals_report
    db_totals = CsvTool.new.get_db_table_list.sort.map do |e|
      [e.pluralize, e.constantize.all.count]
    end.to_h

    puts "\n\n#{'='*40}\n=== Report: DB Totals ==="
    puts db_totals.to_yaml
  end



# CALL: Reporter.link_text_report
  def self.link_text_report

    ## TRYING TO DETERMINE WHICH TEMPLATES USE WHICH LINKS MOST OFTEN ##

    staff_texts = Text.where(text_type: 'staff').map do |el|
      binding.pry
      text = el.text
      text_webs = el.webs

      templates = []
      text_webs_templates = text_webs.map do |web|
        binding.pry
        templates << web.templates
        puts templates
      end

      puts templates

      binding.pry



      [el.text, el.webs.count]
    end.sort {|a,b| b[1]<=>a[1]}.to_h

    puts "\n====== staff_texts =============\n\n"
    puts staff_texts.to_yaml
    binding.pry






    binding.pry
    ## BELOW WORKING PERFECTLY!! - EXPERIMENTING ABOVE ##
    binding.pry
    binding.pry


    staff_texts = Text.where(text_type: 'staff').map do |el|
      [el.text, el.webs.count]
    end.sort {|a,b| b[1]<=>a[1]}.to_h

    puts "\n====== staff_texts =============\n\n"
    puts staff_texts.to_yaml
    binding.pry


    locations_texts = Text.where(text_type: 'locations').map do |el|
      [el.text, el.webs.count]
    end.sort {|a,b| b[1]<=>a[1]}.to_h

    puts "\n====== locations_texts =============\n\n"
    puts locations_texts.to_yaml
    binding.pry





    staff_links = Link.where(link_type: 'staff').map do |el|
      [el.link, el.webs.count]
    end.sort {|a,b| b[1]<=>a[1]}.to_h

    puts "\n====== staff_links =============\n\n"
    puts staff_links.to_yaml
    binding.pry


    locations_links = Link.where(link_type: 'locations').map do |el|
      [el.link, el.webs.count]
    end.sort {|a,b| b[1]<=>a[1]}.to_h

    puts "\n\n======== locations_links ===========\n\n"
    puts locations_links.to_yaml
    binding.pry

  end



end
