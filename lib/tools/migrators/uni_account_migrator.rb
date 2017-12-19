module UniAccountMigrator

  #Call: AboutMigrator.new.migrate_uni_accounts
  def migrate_uni_accounts
    binding.pry

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

end
