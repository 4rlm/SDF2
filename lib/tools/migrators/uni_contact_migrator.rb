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
          # FORMAT INCOMING DATA ROW FROM UniContact.
          uni_contact_hash = uni_contact.attributes
          uni_contact_hash.delete('id')
          uni_contact_hash['id'] = uni_contact_hash.delete('contact_id')
          uni_contact_hash.delete_if { |key, value| value.blank? }

          # CREATE CONTACT HASH, AND ARRAY OF NON-CONTACT DATA FROM ROW.
          uni_contact_array = uni_contact_hash.to_a
          contact_hash = validate_hash(Contact.column_names, uni_contact_array.to_h)
          non_contact_attributes_array = uni_contact_array - contact_hash.to_a
          url = uni_contact_hash['url'] ## Needed up here, because used to find Account ID

          # FIND OR CREATE ACCOUNT, THEN UPDATE IF APPLICABLE
          # Need to identify account before contact, to save account id in contact - less DB hits.
          account_id = uni_contact_hash['account_id']
          account_hash = validate_hash(Account.column_names, non_contact_attributes_array.to_h)
          crm_acct_num = uni_contact_hash['crm_acct_num']
          account = Account.find(account_id) if account_id.present?
          account = Account.find_by(crm_acct_num: crm_acct_num) if (!account.present? && crm_acct_num.present?)

          if (!account.present? && url.present?)
            web_object = Web.find_by(url: url)
            account = web_object.accounts.first if web_object.present?
          end
          account.present? ? update_obj_if_changed(account_hash, account) : account = Account.create(account_hash)

          # FIND OR CREATE CONTACT, THEN UPDATE IF APPLICABLE
          contact_hash['account_id'] = account.id if !contact_hash['account_id']
          cont_id = contact_hash['id']
          crm_cont_num = uni_contact_hash['crm_cont_num']
          email = uni_contact_hash['email']
          contact = Contact.find(cont_id) if cont_id.present?
          contact = Contact.find_by(crm_cont_num: crm_cont_num) if (!contact.present? && crm_cont_num.present?)
          contact = Contact.find_by(email: email) if (!contact.present? && email.present?)
          contact.present? ? update_obj_if_changed(contact_hash, contact) : contact = Contact.create(contact_hash)

          # FIND OR CREATE WEB, THEN UPDATE IF APPLICABLE
          web_hash = validate_hash(Web.column_names, non_contact_attributes_array.to_h) if url.present?
          web_obj = save_complex_object('web', {'url' => url}, web_hash) if url.present?
          create_object_parent_association('web', web_obj, contact) if web_obj.present?

          # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
          phone = uni_contact_hash['phone']
          phone = PhoneFormatter.validate_phone(phone) if phone.present?
          phone_obj = save_simple_object('phone', obj_hash={'phone' => phone}) if phone.present?
          create_object_parent_association('phone', phone_obj, contact) if phone_obj.present?

          # FIND OR CREATE TITLE, THEN UPDATE IF APPLICABLE
          job_title = uni_contact_hash['job_title']
          title_obj = save_simple_object('title', {'job_title' => job_title}) if job_title.present?
          create_object_parent_association('title', title_obj, contact) if title_obj

          # FIND OR CREATE DESCRIPTION, THEN UPDATE IF APPLICABLE
          job_description = uni_contact_hash['job_description']
          description_obj = save_simple_object('description', {'job_description' => job_description}) if job_description.present?
          create_object_parent_association('description', description_obj, contact) if description_obj.present?

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
