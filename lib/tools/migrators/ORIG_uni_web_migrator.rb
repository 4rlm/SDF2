# Note: Web CSV data uploads to UniWeb Table.  Then UniWebMigrator parses it and migrates it to proper tables with associations (Web, Link, Text).  Access parent in Migrator class.

module UniWebMigrator

  #Call: Migrator.new.migrate_uni_webs
  def migrate_uni_webs

    @staff_links = []
    @locations_links = []
    @staff_texts = []
    @locations_texts = []

    @rollbacks = []
    # UniWeb.all.each do |uni_web|
    # UniWeb.find((1..100).to_a).each do |uni_web|
    UniWeb.in_batches.each do |each_batch|
      each_batch.each do |uni_web|

        begin
          # FORMAT INCOMING DATA ROW FROM UniWeb.
          uni_web_hash = uni_web.attributes
          uni_web_hash['url'] = WebFormatter.format_url(uni_web_hash['url'])
          uni_web_hash.delete('id')
          uni_web_hash.delete('url_redirect_id')

          if uni_web_hash['redirect_url'].present?
            uni_web_hash['redirect_url'] = WebFormatter.format_url(uni_web_hash['redirect_url'])
            redirect_url = uni_web_hash['redirect_url']
            redirect_web_obj = save_simple_object('web', {'url' => redirect_url}) if redirect_url.present?
            uni_web_hash['url_redirect_id'] = redirect_web_obj.id if redirect_web_obj.present?
          end

          # CREATE WEB HASH, AND VALIDATE
          uni_web_hash.delete_if { |key, value| value.blank? }
          uni_web_array = uni_web_hash.to_a
          web_hash = validate_hash(Web.column_names, uni_web_array.to_h)
          url = web_hash['url']
          web_obj = save_complex_object('web', {'url' => url}, web_hash) if url.present?

          non_web_attributes_array = uni_web_array - web_hash.to_a
          link_text_hash = non_web_attributes_array.to_h

          #########################
          ### LINK METHODS BELOW ###
          #########################

          # FORMAT staff_link
          staff_link = link_text_hash['staff_link']
          link_text_hash['staff_link'] = WebFormatter.format_link(url, staff_link) if staff_link.present?
          staff_link = link_text_hash['staff_link']

          # FIND OR CREATE staff_link_obj
          if staff_link.present?
            @staff_links << staff_link
            staff_link_hash = {link: staff_link, link_type: 'staff', link_status: link_text_hash['link_status']}
            staff_link_hash.delete_if { |key, value| value.blank? }
            staff_link_obj = save_complex_object('link', {'link' => staff_link}, staff_link_hash)
            create_object_parent_association('link', staff_link_obj, web_obj) if staff_link_obj.present?
          end

          #########################

          # FORMAT locations_link
          locations_link = link_text_hash['locations_link']
          link_text_hash['locations_link'] = WebFormatter.format_link(url, locations_link) if locations_link.present?
          locations_link = link_text_hash['locations_link']

          # FIND OR CREATE locations_link_obj
          if locations_link.present?
            @locations_links << locations_link
            locations_link_hash = {link: locations_link, link_type: 'locations', link_status: link_text_hash['link_status']}
            locations_link_obj = save_complex_object('link', {'link' => locations_link}, locations_link_hash)
            create_object_parent_association('link', locations_link_obj, web_obj) if locations_link_obj.present?
          end

          #########################
          ### TEXT METHODS BELOW ###
          #########################

          # FORMAT staff_text
          staff_text = link_text_hash['staff_text']
          link_text_hash['staff_text'] = WebFormatter.remove_invalid_texts(staff_text) if staff_text.present?
          staff_text = link_text_hash['staff_text']

          if staff_text.present?
            @staff_texts << staff_text
            staff_text_hash = {text: staff_text, text_type: 'staff', text_status: link_text_hash['staff_link_status']}
            staff_text_hash.delete_if { |key, value| value.blank? }
            staff_text_obj = save_complex_object('text', {'text' => staff_text}, staff_text_hash)
            create_object_parent_association('text', staff_text_obj, web_obj) if staff_text_obj.present?
          end

          #########################

          # FIND OR CREATE locations_text_obj
          locations_text = link_text_hash['locations_text']
          link_text_hash['locations_text'] = WebFormatter.remove_invalid_texts(locations_text) if locations_text.present?
          locations_text = link_text_hash['locations_text']

          if locations_text.present?
            @locations_texts << locations_text
            locations_text_hash = {text: locations_text, text_type: 'locations', text_status: link_text_hash['locations_link_status']}
            locations_text_hash.delete_if { |key, value| value.blank? }
            locations_text_obj = save_complex_object('text', {'text' => locations_text}, locations_text_hash)
            create_object_parent_association('text', locations_text_obj, web_obj) if locations_text_obj.present?
          end

        rescue
          puts "\n\nRESCUE ERROR!!\n\n"
          @rollbacks << uni_web_hash
        end

      end ## end of batch iteration.

      #Call: Migrator.new.migrate_uni_webs
      puts "\n\n#{'='*40}"
      puts "staff_links: #{@staff_links.uniq.sort!}"
      puts "\nlocations_links: #{@locations_links.uniq.sort!}"

      puts "\nstaff_texts: #{@staff_texts.uniq.sort!}"
      puts "\nlocations_texts: #{@locations_texts.uniq.sort!}"
      puts "#{'='*40}\n\n"

      puts "Sleep(1) - Report: Links and Texts"
      sleep(1)

    end ## end of in_batches iteration

    puts "\n\n#{'='*40}"
    puts "staff_links: #{@staff_links.uniq.sort!}"
    puts "\nlocations_links: #{@locations_links.uniq.sort!}"

    puts "\nstaff_texts: #{@staff_texts.uniq.sort!}"
    puts "\nlocations_texts: #{@locations_texts.uniq.sort!}"
    puts "#{'='*40}\n\n"

    puts "Sleep(3) - FINAL Report: Links and Texts"
    sleep(3)

    # @rollbacks.each { |uni_web_hash| puts uni_web_hash }
    UniWeb.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_webs')
  end

end
