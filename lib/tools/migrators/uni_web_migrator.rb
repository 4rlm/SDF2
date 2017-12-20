# Note: Web CSV data uploads to UniWeb Table.  Then UniWebMigrator parses it and migrates it to proper tables with associations (Web, Link, Text).  Access parent in Migrator class.

module UniWebMigrator

  #Call: Migrator.new.migrate_uni_webs
  def migrate_uni_webs
    binding.pry

    @rollbacks = []
    # UniWeb.all.each do |uni_web|
    # UniWeb.find((1..100).to_a).each do |uni_web|
    UniWeb.in_batches.each do |each_batch|
      binding.pry

      each_batch.each do |uni_web|
        binding.pry

        begin
          # FORMAT INCOMING DATA ROW FROM UniWeb.
          uni_web_hash = uni_web.attributes
          uni_web_hash.delete('id')
          uni_web_hash.delete_if { |key, value| value.blank? }
          binding.pry

          # CREATE WEB HASH, AND ARRAY OF NON-WEB DATA FROM ROW.
          uni_web_array = uni_web_hash.to_a
          web_hash = validate_hash(Web.column_names, uni_web_array.to_h)
          non_web_attributes_array = uni_web_array - web_hash.to_a
          link_text_hash = non_web_attributes_array.to_h
          binding.pry

          web_hash # see what's in here.
          # url = web_hash[:url]

          # FIND OR CREATE Web (url), THEN UPDATE IF APPLICABLE

          # FIND OR CREATE Link (staff/location page), THEN UPDATE IF APPLICABLE
          link_text_hash ## See what's in here, then do something like below:
          binding.pry
          staff_link = link_text_hash[:staff_link]
          staff_link_status = link_text_hash[:staff_link_status]
          binding.pry

          locations_link = link_text_hash[:locations_link]
          locations_link_status = link_text_hash[:locations_link_status]
          binding.pry

          ## Create hash to match UniWeb with Link col names; Slightly dif.
          staff_link_hash = {link: staff_link, link_type: 'staff', link_status: staff_link_status}

          locations_link_hash = {link: locations_link, link_type: 'locations', link_status: locations_link_status}

          # loc_link_hash = {}


          # link_hash = validate_hash(Link.column_names, non_contact_attributes_array.to_h) if url.present?
          # save_complex_object('web', contact, {'url' => url}, link_hash) if url.present?


          # FIND OR CREATE Text (staff/location href), THEN UPDATE IF APPLICABLE




          # url = uni_web_hash['url'] ## Needed up here, because used to find Account ID

        rescue
          binding.pry
        end

      end
    end
  end

end
