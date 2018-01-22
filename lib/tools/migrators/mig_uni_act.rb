# Note: Act CSV data uploads to UniAct Table.  Then MigUniAct parses it and migrates it to proper tables with associations.  Access parent in Mig class.

module MigUniAct

  #Call: Mig.new.migrate_uni_acts
  def migrate_uni_acts

    @rollbacks = []
    # UniAct.all.each do |uni_act|
    # UniAct.find((1..603).to_a).each do |uni_act|
    UniAct.in_batches.each do |each_batch|
      each_batch.each do |uni_act|

        begin
          # FORMAT INCOMING DATA ROW FROM UniAct.
          # UNI CONTACT HASH: FORMAT INCOMING DATA ROW FROM UniCont.
          uni_hsh = uni_act.attributes
          uni_hsh = uni_hsh.symbolize_keys
          uni_hsh.delete(:id)
          uni_hsh[:id] = uni_hsh.delete(:act_id)
          uni_hsh.delete_if { |key, value| value.blank? }
          #########################################################

          # CREATE ACCOUNT HASH, AND ARRAY OF NON-ACCOUNT DATA FROM ROW.
          uni_act_arr = uni_hsh.stringify_keys.to_a
          act_hsh = val_hsh(Act.column_names, uni_act_arr.to_h)
          non_act_attributes_array = uni_act_arr - act_hsh.stringify_keys.to_a
          #########################################################

          # CREATE WEB HASH, and format Url, then save formatted url back into WEB HASH, and to url var.
          web_hsh = val_hsh(Web.column_names, non_act_attributes_array.to_h) if uni_hsh[:url].present?
          web_hsh[:url] = @formatter.format_url(web_hsh[:url]) if web_hsh.present?
          url = web_hsh[:url] if web_hsh.present?
          #########################################################

          # FIND OR CREATE URL, THEN UPDATE IF APPLICABLE
          web_obj = save_comp_obj('web', {url: url}, web_hsh) if url.present?
          #########################################################

          # FIND OR CREATE TEMPLATE, THEN UPDATE IF APPLICABLE
          temp_name = uni_hsh[:temp_name]
          template_obj = save_simp_obj('template', {temp_name: temp_name}) if temp_name.present?
          #########################################################

          # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
          phone = uni_hsh[:phone]
          phone = @formatter.validate_phone(phone) if phone.present?
          phone_obj = save_simp_obj('phone', obj_hsh={'phone' => phone}) if phone.present?
          #########################################################

          # FIND OR CREATE ADDRESS, THEN UPDATE IF APPLICABLE
          adr_hsh = val_hsh(Adr.column_names, non_act_attributes_array.to_h)
          adr_hsh = @formatter.format_adr_hsh(adr_hsh) if adr_hsh && !adr_hsh.empty?
          adr_obj = save_simp_obj('adr', adr_hsh) if adr_hsh && !adr_hsh.empty?
          #########################################################

          # FIND OR CREATE WHO, THEN UPDATE IF APPLICABLE
          # if uni_hsh[:ip] || uni_hsh[:server1] || uni_hsh[:server2]
          #   who_hsh = val_hsh(Who.column_names, non_act_attributes_array.to_h)
          #   who_obj = Who.find_or_create_by(who_hsh)
          #   who_obj.webs << web_obj if (web_obj && !who_obj.webs.include?(web_obj))
          # end
          #########################################################

          ## Need final formatted City and State to add to act_name, so Associations with parent moved to bottom, so to find or create by act_name based on attached city and state.

          # FIND OR CREATE ACCOUNT, THEN UPDATE IF APPLICABLE
          crma = act_hsh[:crma]
          act_id = act_hsh[:id]

          act_name = act_hsh[:act_name]
          act_name&.gsub!(',', ' ')
          city = adr_hsh[:city]
          state = adr_hsh[:state]

          if city.present? && state.present?
            act_name = "#{act_name} in #{city}, #{state}"
          elsif city.present?
            act_name = "#{act_name} in #{city}"
          elsif state.present?
            act_name = "#{act_name} in #{state}"
          end

          act_hsh[:act_name] = @formatter.format_act_name_lite(act_name) if act_hsh.present?
          act_name = act_hsh[:act_name]
          #########################################################


          ######## Find or Create Act Based on ID, CRM, Name, or Url ########
          if act_id.present?
            act_obj = Act.find_by(id: act_id)
          elsif crma.present?
            act_obj = Act.find_by(crma: crma)
          elsif act_name.present?
            temp_act = Act.find_by(act_name: act_name)
            temp_web = temp_act.webs.find { |web| web&.url == url } if temp_act.present?
            act_obj ||= temp_web&.acts&.first || act_obj = temp_act if temp_act.present?
          end
          act_obj.present? ? update_obj_if_changed(act_hsh, act_obj) : act_obj = Act.create(act_hsh)
          #########################################################

          ############## Create Parent Associations ##############
          create_obj_parent_assoc('web', web_obj, act_obj) if web_obj.present?
          create_obj_parent_assoc('template', template_obj, web_obj) if template_obj && web_obj
          create_obj_parent_assoc('phone', phone_obj, act_obj) if phone_obj.present?
          create_obj_parent_assoc('adr', adr_obj, act_obj) if adr_obj
          #########################################################

        rescue StandardError => error
          puts "\n\n=== RESCUE ERROR!! ==="
          puts error.class.name
          puts error.message
          print error.backtrace.join("\n")
          @rollbacks << uni_hsh
        end

      end ## end of batch iteration.
    end ## end of in_batches iteration

    @rollbacks.each { |uni_hsh| puts uni_hsh }
    # UniAct.destroy_all

    UniAct.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_acts')
  end

end
