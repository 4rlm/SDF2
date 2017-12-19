# IMPORTANT: Works with /lib/csv/csv_tool_mod.rb

# 1) Note: Ensure config/application.rb extends autoload to concerns.
# 2) Migrates uni_account AND uni_contact tableS (csv imported accounts/contacts) to their proper join tables, then deletes itself.

require 'pry'

class AboutMigrator

  def migrate_uni_accounts
    # AboutMigrator.new.migrate_uni_accounts

    @rollbacks = []
    # UniAccount.all.each do |uni_account|
    # UniAccount.find((1..603).to_a).each do |uni_account|
    UniAccount.in_batches.each do |each_batch|
      each_batch.each do |uni_account|

        begin
          # FORMAT INCOMING DATA ROW FROM UniAccount.
          uni_account_hash = uni_account.attributes
          uni_account_hash.delete('id')
          uni_account_hash['id'] = uni_account_hash.delete('account_id')
          uni_account_hash.delete_if { |key, value| value.blank? }

          # CREATE ACCOUNT HASH, AND ARRAY OF NON-ACCOUNT DATA FROM ROW.
          uni_account_array = (uni_account_hash.to_a)
          account_hash = validate_hash(Account.column_names, uni_account_array.to_h)
          non_account_attributes_array = uni_account_array - account_hash.to_a
          url = uni_account_hash['url']

          # FIND OR CREATE ACCOUNT, THEN UPDATE IF APPLICABLE
          crm_acct_num = account_hash['crm_acct_num']
          acct_id = account_hash['id']
          account_name = account_hash['account_name']

          # account = Account.find(acct_id) if acct_id
          # account = Account.find_by(crm_acct_num: crm_acct_num) if (!account && crm_acct_num)

          if acct_id
            account = Account.find(acct_id)
          elsif !account && crm_acct_num
            account = Account.find_by(crm_acct_num: crm_acct_num)
          elsif !account && account_name
            provisional_account = Account.find_by(account_name: account_name)

            if provisional_account
              provisional_web = provisional_account.webs.find { |web| web.url == url }

              if provisional_web
                account = provisional_web.accounts.first
              elsif !provisional_account.crm_acct_num
                account = provisional_account
              end

            end

          end
          account ? update_obj_if_changed(account_hash, account) : account = Account.create(account_hash)
          ## AboutMigrator.new.migrate_uni_accounts

          # FIND OR CREATE URL, THEN UPDATE IF APPLICABLE
          web_hash = validate_hash(Web.column_names, non_account_attributes_array.to_h) if url.present?
          web_obj = save_complex_association('web', account, {'url' => url}, web_hash) if url.present?

          # binding.pry

          ## Consider using WebFormatter.migrate_web_and_links(id) via lib/tools/formatters/web_formatter.rb
          ## Will need to modify it to accomodate the data here.  Perhaps have it return a value at the end, too.

          ## Slightly tricky.  Need to create two records in Links Table.  One for staff and another for locations.  Col names won't match the incoming hash csv fiels names, so will have to do some customizing.

          ## Need to parse out staff_page and locations_page to Links before importing, because those cols have been removed from Webs Table.

          ## Also need to parse the main url out of the staff and locations page.
          links_hash = validate_hash(Link.column_names, non_account_attributes_array.to_h) if url.present?
          # link | link_type | link_status

          # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
          phone = uni_account_hash['phone']
          save_simple_association('phone', account, obj_hash={'phone' => phone}) if phone.present?

          # FIND OR CREATE ADDRESS, THEN UPDATE IF APPLICABLE
          address_hash = validate_hash(Address.column_names, non_account_attributes_array.to_h)
          address_concat = address_hash.values.compact.join(',')
          if address_concat

            zip = address_hash['zip']
            if zip && zip.length == 4
              zip = "0#{zip}"
              address_hash['zip'] = zip
            end

            full_address = address_hash.except('address_pin').values.compact.join(', ')
            address_hash['full_address'] = full_address
            save_complex_association('address', account, {'full_address' => full_address}, address_hash)
          end

          # FIND OR CREATE TEMPLATE, THEN UPDATE IF APPLICABLE
          template_name = uni_account_hash['template_name']
          save_simple_association('template', account, obj_hash={'template_name' => template_name}) if template_name.present?

          # FIND OR CREATE WHO, THEN UPDATE IF APPLICABLE
          if uni_account_hash['ip'] || uni_account_hash['server1'] || uni_account_hash['server2']
            who_hash = validate_hash(Who.column_names, non_account_attributes_array.to_h)
            who_obj = Who.find_or_create_by(who_hash)
            who_obj.webs << web_obj if (web_obj && !who_obj.webs.include?(web_obj))
          end

        rescue
          puts "\n\nRESCUE ERROR!!\n\n"
          @rollbacks << uni_account_hash
        end
      end ## end of iteration.
    end

    @rollbacks.each { |uni_account_hash| puts uni_account_hash }
    # UniAccount.destroy_all

    UniAccount.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_accounts')
  end



  def migrate_uni_contacts
    # AboutMigrator.new.migrate_uni_contacts

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
          account = Account.find(account_id) if account_id
          account = Account.find_by(crm_acct_num: crm_acct_num) if (!account && crm_acct_num)

          if (!account && url)
            web_object = Web.find_by(url: url)
            account = web_object.accounts.first if web_object
          end
          account ? update_obj_if_changed(account_hash, account) : account = Account.create(account_hash)

          # FIND OR CREATE CONTACT, THEN UPDATE IF APPLICABLE
          contact_hash['account_id'] = account.id if !contact_hash['account_id']
          cont_id = contact_hash['id']
          crm_cont_num = uni_contact_hash['crm_cont_num']
          email = uni_contact_hash['email']
          contact = Contact.find(cont_id) if cont_id
          contact = Contact.find_by(crm_cont_num: crm_cont_num) if (!contact && crm_cont_num)
          contact = Contact.find_by(email: email) if (!contact && email)
          contact.present? ? update_obj_if_changed(contact_hash, contact) : contact = Contact.create(contact_hash)

          # FIND OR CREATE WEB, THEN UPDATE IF APPLICABLE
          web_hash = validate_hash(Web.column_names, non_contact_attributes_array.to_h) if url.present?
          save_complex_association('web', contact, {'url' => url}, web_hash) if url.present?

          # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
          phone = uni_contact_hash['phone']
          save_simple_association('phone', contact, {'phone' => phone}) if phone.present?

          # FIND OR CREATE TITLE, THEN UPDATE IF APPLICABLE
          job_title = uni_contact_hash['job_title']
          save_simple_association('title', contact, {'job_title' => job_title}) if job_title.present?

          # FIND OR CREATE DESCRIPTION, THEN UPDATE IF APPLICABLE
          job_description = uni_contact_hash['job_description']
          save_simple_association('description', contact, {'job_description' => job_description}) if job_description.present?

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


  def save_simple_association(model, parent, attr_hash)
    obj = model.classify.constantize.find_or_create_by(attr_hash)
    parent.send(model.pluralize.to_sym) << obj if (obj && !parent.send(model.pluralize.to_sym).include?(obj))

    # if phone.present?
    #   phone_obj = Phone.find_or_create_by(phone: phone)
    #   account.phones << phone_obj if !account.phones.include?(phone_obj)
    # end
    return obj if obj
  end


  def save_complex_association(model, parent, attr_hash, obj_hash)
    obj = model.classify.constantize.find_by(attr_hash)
    obj.present? ? update_obj_if_changed(obj_hash, obj) : obj = model.classify.constantize.create(obj_hash)
    parent.send(model.pluralize.to_sym) << obj if (obj && !parent.send(model.pluralize.to_sym).include?(obj))

    # if url.present?
    #   web_obj = Web.find_by(url: url)
    #   web_obj.present? ? update_obj_if_changed(web_hash, web_obj) : web_obj = Web.create(web_hash)
    #   contact.webs << web_obj if !contact.webs.include?(web_obj)
    # end
    return obj if obj
  end


  def update_obj_if_changed(hash, obj)
    hash.delete_if { |k, v| v.nil? }

    if hash['updated_at']
      hash.delete('updated_at')
      obj.record_timestamps = false
    end

    updated_attributes = (hash.values) - (obj.attributes.values)
    obj.update_attributes(hash) if !updated_attributes.empty?
  end


  def validate_hash(cols, hash)
    # cols.map!(&:to_sym)
    keys = hash.keys
    keys.each { |key| hash.delete(key) if !cols.include?(key) }
    return hash
  end


end
