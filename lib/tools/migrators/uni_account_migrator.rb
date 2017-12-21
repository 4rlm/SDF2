# Note: Account CSV data uploads to UniAccount Table.  Then UniAccountMigrator parses it and migrates it to proper tables with associations.  Access parent in Migrator class.

module UniAccountMigrator

  #Call: Migrator.new.migrate_uni_accounts
  def migrate_uni_accounts

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
          # url = uni_account_hash['url']
          web_hash = validate_hash(Web.column_names, non_account_attributes_array.to_h) if uni_account_hash['url'].present?
          web_hash['url'] = WebFormatter.format_url(web_hash['url'])
          url = web_hash['url']

          # FIND OR CREATE ACCOUNT, THEN UPDATE IF APPLICABLE
          crm_acct_num = account_hash['crm_acct_num']
          acct_id = account_hash['id']
          account_name = account_hash['account_name']

          if acct_id.present?
            account = Account.find(acct_id)
          elsif !account.present? && crm_acct_num.present?
            account = Account.find_by(crm_acct_num: crm_acct_num)
          elsif !account.present? && account_name.present?
            provisional_account = Account.find_by(account_name: account_name)

            if provisional_account.present?
              provisional_web = provisional_account.webs.find { |web| web.url == url }

              if provisional_web.present?
                account = provisional_web.accounts.first
              elsif !provisional_account.crm_acct_num.present?
                account = provisional_account
              end
            end
          end
          account.present? ? update_obj_if_changed(account_hash, account) : account = Account.create(account_hash)

          # FIND OR CREATE URL, THEN UPDATE IF APPLICABLE
          # NOTE: PART OF WEB IS ATOP BECAUSE URL REQUIRED FOR FINDING SOME ACCOUNTS.
          web_obj = save_complex_object('web', {'url' => url}, web_hash) if url.present?
          create_object_parent_association('web', web_obj, account) if web_obj.present?

          # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
          phone = uni_account_hash['phone']
          phone = PhoneFormatter.validate_phone(phone) if phone.present?
          phone_obj = save_simple_object('phone', obj_hash={'phone' => phone}) if phone.present?
          create_object_parent_association('phone', phone_obj, account) if phone_obj.present?

          # FIND OR CREATE ADDRESS, THEN UPDATE IF APPLICABLE
          address_hash = validate_hash(Address.column_names, non_account_attributes_array.to_h)
          address_hash = AddressFormatter.format_address_hash(address_hash) if !address_hash.empty?
          address_obj = save_simple_object('address', address_hash) if !address_hash.empty?
          create_object_parent_association('address', address_obj, account) if address_obj

          # FIND OR CREATE TEMPLATE, THEN UPDATE IF APPLICABLE
          template_name = uni_account_hash['template_name']
          template_obj = save_simple_object('template', obj_hash={'template_name' => template_name}) if template_name.present?
          # create_object_parent_association('template', template_obj, account) ## NOT JOINING THEM ANYMORE.  GO THROUGH WEB.
          create_object_parent_association('template', template_obj, web_obj) if template_obj.present?


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

      end ## end of batch iteration.
    end ## end of in_batches iteration

    @rollbacks.each { |uni_account_hash| puts uni_account_hash }
    # UniAccount.destroy_all

    UniAccount.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_accounts')
  end

end
