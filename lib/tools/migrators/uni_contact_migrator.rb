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
          # UNI CONTACT HASH: FORMAT INCOMING DATA ROW FROM UniContact.
          uni_contact_hash = uni_contact.attributes
          uni_contact_hash.delete('id')
          uni_contact_hash.delete('contact_id')
          uni_contact_hash['url'] = WebFormatter.format_url(uni_contact_hash['url'])
          uni_contact_hash.delete_if { |key, value| value.blank? }

          # CONTACT HASH: CREATED FROM uni_contact_hash
          uni_contact_array = uni_contact_hash.to_a
          cont_hash = validate_hash(Contact.column_names, uni_contact_array.to_h)
          non_contact_attributes_array = uni_contact_array - cont_hash.to_a

          # WEB OBJECT: FIND, CREATE (saves association after account obj created)
          web_obj = save_simple_object('web', {'url' => uni_contact_hash['url']})

          # ACCOUNT OBJECT: FIND, CREATE, UPDATE
          acct_hash = validate_hash(Account.column_names, non_contact_attributes_array.to_h)
          acct_obj ||= Account.find_by(id: uni_contact_hash['account_id']) || Account.find_by(crm_acct_num: uni_contact_hash['crm_acct_num']) || web_obj.try(:accounts)[0]
          acct_obj.present? ? update_obj_if_changed(acct_hash, acct_obj) : acct_obj = Account.create(acct_hash)
          cont_hash['account_id'] = acct_obj.id

          # WEB OBJECT: SAVE ASSOCIATION
          create_object_parent_association('web', web_obj, acct_obj)

          # CONTACT OBJECT: FIND, CREATE, UPDATE
          cont_hash.delete_if { |key, value| value.blank? }
          cont_obj ||= Contact.find_by(id: cont_hash['id']) || Contact.find_by(crm_cont_num: uni_contact_hash['crm_cont_num']) || Contact.find_by(email: uni_contact_hash['email'])
          cont_obj.present? ? update_obj_if_changed(cont_hash, cont_obj) : cont_obj = Contact.create(cont_hash)

          # CONTACT OBJECT: SAVE ASSOCIATION
          create_object_parent_association('contact', cont_obj, acct_obj)

          # PHONE OBJECT: FIND or CREATE, then SAVE ASSOCIATION
          phone = PhoneFormatter.validate_phone(uni_contact_hash['phone'])
          phone_obj = save_simple_object('phone', obj_hash={'phone' => phone})
          create_object_parent_association('phone', phone_obj, cont_obj)

          # TITLE OBJECT: FIND or CREATE, then SAVE ASSOCIATION
          title_obj = save_simple_object('title', {'job_title' => uni_contact_hash['job_title']})
          create_object_parent_association('title', title_obj, cont_obj)

          # DESCRIPTION OBJECT: FIND or CREATE, then SAVE ASSOCIATION
          description_obj = save_simple_object('description', {'job_description' => uni_contact_hash['job_description']})
          create_object_parent_association('description', description_obj, cont_obj)

        rescue
          puts "\n\nRESCUE ERROR!!\n\n"
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
