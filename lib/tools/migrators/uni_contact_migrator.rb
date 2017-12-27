# Note: Contact CSV data uploads to UniContact Table.  Then UniContactMigrator parses it and migrates it to proper tables with associations.  Access parent in Migrator class.

module UniContactMigrator

  #Call: Migrator.new.migrate_uni_contacts
  def migrate_uni_contacts

    @rollbacks = []
    # UniContact.all.each do |uni_contact|
    # UniContact.find((1..100).to_a).each do |uni_contact|
    UniContact.in_batches.each do |each_batch|
      each_batch.each do |uni_contact|

        begin
          # UNI CONT HASH: FORMAT INCOMING DATA ROW FROM UniContact.
          uni_hsh = uni_contact.attributes
          uni_hsh.delete('id')
          uni_hsh.delete('contact_id')
          uni_hsh['url'] = WebFormatter.format_url(uni_hsh['url']) if uni_hsh['url'].present?
          uni_hsh.delete_if { |key, value| value.blank? }

          # CONT HASH: CREATED FROM uni_hsh
          uni_contact_array = uni_hsh.to_a
          cont_hsh = validate_hsh(Contact.column_names, uni_contact_array.to_h)
          non_contact_attributes_array = uni_contact_array - cont_hsh.to_a

          # WEB OBJ: FIND, CREATE (saves association after account obj created)
          web_obj = save_simple_obj('web', {'url' => uni_hsh['url']}) if uni_hsh['url'].present?

          # ACCOUNT OBJ: FIND, CREATE, UPDATE
          acct_hsh = validate_hsh(Account.column_names, non_contact_attributes_array.to_h)
          acct_obj ||= Account.find_by(id: uni_hsh['account_id']) || Account.find_by(crm_acct_num: uni_hsh['crm_acct_num']) || web_obj&.accounts&.first

          acct_obj.present? ? update_obj_if_changed(acct_hsh, acct_obj) : acct_obj = Account.create(acct_hsh)
          cont_hsh['account_id'] = acct_obj&.id

          # WEB OBJ: SAVE ASSOC
          create_obj_parent_assoc('web', web_obj, acct_obj) if web_obj && acct_obj

          # CONT OBJ: FIND, CREATE, UPDATE
          cont_hsh.delete_if { |key, value| value.blank? }

          if cont_hsh['id'].present?
            cont_obj = Contact.find_by(id: cont_hsh['id'])
          elsif uni_hsh['crm_cont_num'].present?
            cont_obj = Contact.find_by(crm_cont_num: uni_hsh['crm_cont_num'])
          elsif uni_hsh['email']
            cont_obj = Contact.find_by(email: uni_hsh['email'])
          end

          # cont_obj ||= Contact.find_by(id: cont_hsh['id']) || Contact.find_by(crm_cont_num: uni_hsh['crm_cont_num']) || Contact.find_by(email: uni_hsh['email'])
          cont_obj.present? ? update_obj_if_changed(cont_hsh, cont_obj) : cont_obj = Contact.create(cont_hsh)

          # CONT OBJ: SAVE ASSOC
          # create_obj_parent_assoc('contact', cont_obj, acct_obj) if cont_obj && acct_obj
          if cont_obj && acct_obj
            create_obj_parent_assoc('contact', cont_obj, acct_obj)
          else
            binding.pry
          end


          # PHONE OBJ: FIND-CREATE, then SAVE ASSOC
          phone = PhoneFormatter.validate_phone(uni_hsh['phone']) if uni_hsh['phone'].present?
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
          @rollbacks << uni_contact
        end
      end ## end of iteration.
    end

    @rollbacks.each { |uni_contact| puts uni_contact }
    # UniContact.destroy_all

    UniContact.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_contacts')
  end

end
