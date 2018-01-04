# Note: Act CSV data uploads to UniAct Table.  Then UniActMigrator parses it and migrates it to proper tables with associations.  Access parent in Migrator class.

module UniActMigrator

  #Call: Migrator.new.migrate_uni_acts
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
          uni_hsh.delete('id')
          uni_hsh['id'] = uni_hsh.delete('act_id')
          uni_hsh.delete_if { |key, value| value.blank? }

          # CREATE ACCOUNT HASH, AND ARRAY OF NON-ACCOUNT DATA FROM ROW.
          uni_act_array = (uni_hsh.to_a)
          act_hsh = validate_hsh(Act.column_names, uni_act_array.to_h)
          non_act_attributes_array = uni_act_array - act_hsh.to_a

          # CREATE WEB HASH, and format Url, then save formatted url back into WEB HASH, and to url var.
          web_hsh = validate_hsh(Web.column_names, non_act_attributes_array.to_h) if uni_hsh['url'].present?

          # web_hsh['url'] = WebFormatter.format_url(web_hsh['url']) if web_hsh.present?
          web_hsh['url'] = Formatter.new.format_url(web_hsh['url']) if web_hsh.present?
          url = web_hsh['url'] if web_hsh.present?

          # FIND OR CREATE ACCOUNT, THEN UPDATE IF APPLICABLE
          crm_act_num = act_hsh['crm_act_num']
          act_id = act_hsh['id']

          # act_hsh['act_name'] = ActFormatter.format_act_name(act_hsh['act_name']) if act_hsh.present?
          act_hsh['act_name'] = Formatter.new.format_act_name(act_hsh['act_name']) if act_hsh.present?
          act_name = act_hsh['act_name']

          # FIND ACCT based on id, crm_act_num, act_name, or url.
          if act_id.present?
            act = Act.find_by(id: act_id)
          elsif crm_act_num.present?
            act = Act.find_by(crm_act_num: crm_act_num)
          elsif act_name.present?
            temp_act = Act.find_by(act_name: act_name)
            temp_web = temp_act.webs.find { |web| web&.url == url } if temp_act.present?
            act ||= temp_web&.acts&.first || act = temp_act if temp_act.present?
          end
          act.present? ? update_obj_if_changed(act_hsh, act) : act = Act.create(act_hsh)

          ## Above Replaces below.  Need to test if working. ##
          # act ||= Act.try(:find_by, id: act_id) || Act.try(:find_by, crm_act_num: crm_act_num)
          # temp_act = Act.try(:find_by, act_name: act_name) if !act.present?
          # temp_web = temp_act.webs.find { |web| web.url == url } if temp_act.present?

          ## Assign act var to above act var obj, or create a new act object.
          # act ||= temp_web&.acts&.first || act = temp_act
          # act.present? ? update_obj_if_changed(act_hsh, act) : act = Act.create(act_hsh)


          # FIND OR CREATE URL, THEN UPDATE IF APPLICABLE
          # NOTE: PART OF WEB IS ATOP BECAUSE URL REQUIRED FOR FINDING SOME ACCOUNTS.
          web_obj = save_complex_obj('web', {'url' => url}, web_hsh) if url.present?
          create_obj_parent_assoc('web', web_obj, act) if web_obj.present?

          # FIND OR CREATE TEMPLATE, THEN UPDATE IF APPLICABLE
          template_name = uni_hsh['template_name']
          template_obj = save_simple_obj('template', {'template_name' => template_name}) if template_name.present?
          create_obj_parent_assoc('template', template_obj, web_obj) if template_obj && web_obj

          # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
          phone = uni_hsh['phone']
          # phone = PhoneFormatter.validate_phone(phone) if phone.present?
          phone = Formatter.new.validate_phone(phone) if phone.present?

          phone_obj = save_simple_obj('phone', obj_hsh={'phone' => phone}) if phone.present?
          create_obj_parent_assoc('phone', phone_obj, act) if phone_obj.present?

          # FIND OR CREATE ADDRESS, THEN UPDATE IF APPLICABLE
          adr_hsh = validate_hsh(Adr.column_names, non_act_attributes_array.to_h)

          # adr_hsh = AdrFormatter.format_adr_hsh(adr_hsh) if adr_hsh && !adr_hsh.empty?
          adr_hsh = Formatter.new.format_adr_hsh(adr_hsh) if adr_hsh && !adr_hsh.empty?

          adr_obj = save_simple_obj('adr', adr_hsh) if adr_hsh && !adr_hsh.empty?
          create_obj_parent_assoc('adr', adr_obj, act) if adr_obj

          # FIND OR CREATE WHO, THEN UPDATE IF APPLICABLE
          if uni_hsh['ip'] || uni_hsh['server1'] || uni_hsh['server2']
            who_hsh = validate_hsh(Who.column_names, non_act_attributes_array.to_h)
            who_obj = Who.find_or_create_by(who_hsh)
            who_obj.webs << web_obj if (web_obj && !who_obj.webs.include?(web_obj))
          end

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
