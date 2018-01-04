# Note: Cont CSV data uploads to UniCont Table.  Then UniContMigrator parses it and migrates it to proper tables with associations.  Access parent in Migrator class.

module UniContMigrator

  #Call: Migrator.new.migrate_uni_conts
  def migrate_uni_conts

    @rollbacks = []
    # UniCont.all.each do |uni_cont|
    # UniCont.find((1..100).to_a).each do |uni_cont|
    UniCont.in_batches.each do |each_batch|
      each_batch.each do |uni_cont|

        begin
          # UNI CONT HASH: FORMAT INCOMING DATA ROW FROM UniCont.
          uni_hsh = uni_cont.attributes
          uni_hsh.delete('id')
          uni_hsh.delete('cont_id')


          # uni_hsh['url'] = WebFormatter.format_url(uni_hsh['url']) if uni_hsh['url'].present?
          uni_hsh['url'] = Formatter.new.format_url(uni_hsh['url']) if uni_hsh['url'].present?

          uni_hsh.delete_if { |key, value| value.blank? }

          # CONT HASH: CREATED FROM uni_hsh
          uni_cont_array = uni_hsh.to_a
          cont_hsh = validate_hsh(Cont.column_names, uni_cont_array.to_h)
          non_cont_attributes_array = uni_cont_array - cont_hsh.to_a

          # WEB OBJ: FIND, CREATE (saves association after act obj created)
          web_obj = save_simple_obj('web', {'url' => uni_hsh['url']}) if uni_hsh['url'].present?

          # ACCOUNT OBJ: FIND, CREATE, UPDATE
          ## NEED TO FORMAT crm_act_num IF IT IS AN INDEXER 'ACT_SRC: WEB' URL. ##
          ## IF USING URL AS crm_act_num, IT NEEDS TO BE FORMATTED WHEN FINDING ACCOUNT WITH SAME URL!! ##

          act_hsh = validate_hsh(Act.column_names, non_cont_attributes_array.to_h)
          act_obj ||= Act.find_by(id: uni_hsh['act_id']) || Act.find_by(crm_act_num: uni_hsh['crm_act_num']) || web_obj&.acts&.first

          act_obj.present? ? update_obj_if_changed(act_hsh, act_obj) : act_obj = Act.create(act_hsh)
          cont_hsh['act_id'] = act_obj&.id

          # WEB OBJ: SAVE ASSOC
          create_obj_parent_assoc('web', web_obj, act_obj) if web_obj && act_obj

          # CONT OBJ: FIND, CREATE, UPDATE
          cont_hsh.delete_if { |key, value| value.blank? }

          if cont_hsh['id'].present?
            cont_obj = Cont.find_by(id: cont_hsh['id'])
          elsif uni_hsh['crm_cont_num'].present?
            cont_obj = Cont.find_by(crm_cont_num: uni_hsh['crm_cont_num'])
          elsif uni_hsh['email']
            cont_obj = Cont.find_by(email: uni_hsh['email'])
          end

          # cont_obj ||= Cont.find_by(id: cont_hsh['id']) || Cont.find_by(crm_cont_num: uni_hsh['crm_cont_num']) || Cont.find_by(email: uni_hsh['email'])
          cont_obj.present? ? update_obj_if_changed(cont_hsh, cont_obj) : cont_obj = Cont.create(cont_hsh)

          # CONT OBJ: SAVE ASSOC
          # create_obj_parent_assoc('cont', cont_obj, act_obj) if cont_obj && act_obj
          if cont_obj && act_obj
            create_obj_parent_assoc('cont', cont_obj, act_obj)
          # else
          #   binding.pry
          end


          # PHONE OBJ: FIND-CREATE, then SAVE ASSOC
          # phone = PhoneFormatter.validate_phone(uni_hsh['phone']) if uni_hsh['phone'].present?
          phone = Formatter.new.validate_phone(uni_hsh['phone']) if uni_hsh['phone'].present?

          phone_obj = save_simple_obj('phone', {'phone' => phone}) if phone.present?
          create_obj_parent_assoc('phone', phone_obj, cont_obj) if phone_obj && cont_obj

          # TITLE OBJ: FIND-CREATE, then SAVE ASSOC
          title_obj = save_simple_obj('title', {'job_title' => uni_hsh['job_title']}) if uni_hsh['job_title'].present?
          create_obj_parent_assoc('title', title_obj, cont_obj) if title_obj && cont_obj

          # DESCRIPTION OBJ: FIND-CREATE, then SAVE ASSOC
          description_obj = save_simple_obj('description', {'job_description' => uni_hsh['job_description']}) if uni_hsh['job_description'].present?
          create_obj_parent_assoc('description', description_obj, cont_obj) if description_obj && cont_obj

        rescue StandardError => error
          puts "\n\n=== RESCUE ERROR!! ==="
          puts error.class.name
          puts error.message
          print error.backtrace.join("\n")
          binding.pry
          @rollbacks << uni_cont
        end
      end ## end of iteration.
    end

    @rollbacks.each { |uni_cont| puts uni_cont }
    # UniCont.destroy_all

    UniCont.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_conts')
  end

end
