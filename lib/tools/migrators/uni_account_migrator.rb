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
          # UNI CONTACT HASH: FORMAT INCOMING DATA ROW FROM UniContact.
          uni_hsh = uni_account.attributes
          uni_hsh.delete('id')
          uni_hsh['id'] = uni_hsh.delete('account_id')
          uni_hsh.delete_if { |key, value| value.blank? }

          # CREATE ACCOUNT HASH, AND ARRAY OF NON-ACCOUNT DATA FROM ROW.
          uni_account_array = (uni_hsh.to_a)
          account_hsh = validate_hsh(Account.column_names, uni_account_array.to_h)
          non_account_attributes_array = uni_account_array - account_hsh.to_a

          # CREATE WEB HASH, and format Url, then save formatted url back into WEB HASH, and to url var.
          web_hsh = validate_hsh(Web.column_names, non_account_attributes_array.to_h) if uni_hsh['url'].present?
          web_hsh['url'] = WebFormatter.format_url(web_hsh['url']) if web_hsh.present?
          url = web_hsh['url'] if web_hsh.present?

          # FIND OR CREATE ACCOUNT, THEN UPDATE IF APPLICABLE
          crm_acct_num = account_hsh['crm_acct_num']
          acct_id = account_hsh['id']
          account_name = account_hsh['account_name']

          # FIND ACCT based on id, crm_acct_num, account_name, or url.
          if acct_id.present?
            account = Account.find_by(id: acct_id)
          elsif crm_acct_num.present?
            account = Account.find_by(crm_acct_num: crm_acct_num)
          elsif account_name.present?
            temp_acct = Account.find_by(account_name: account_name)
            temp_web = temp_acct.webs.find { |web| web&.url == url } if temp_acct.present?
            account ||= temp_web&.accounts&.first || account = temp_acct if temp_acct.present?
          end
          account.present? ? update_obj_if_changed(account_hsh, account) : account = Account.create(account_hsh)

          ## Above Replaces below.  Need to test if working. ##
          # account ||= Account.try(:find_by, id: acct_id) || Account.try(:find_by, crm_acct_num: crm_acct_num)
          # temp_acct = Account.try(:find_by, account_name: account_name) if !account.present?
          # temp_web = temp_acct.webs.find { |web| web.url == url } if temp_acct.present?

          ## Assign account var to above account var obj, or create a new account object.
          # account ||= temp_web&.accounts&.first || account = temp_acct
          # account.present? ? update_obj_if_changed(account_hsh, account) : account = Account.create(account_hsh)


          # FIND OR CREATE URL, THEN UPDATE IF APPLICABLE
          # NOTE: PART OF WEB IS ATOP BECAUSE URL REQUIRED FOR FINDING SOME ACCOUNTS.
          web_obj = save_complex_obj('web', {'url' => url}, web_hsh) if url.present?
          create_obj_parent_assoc('web', web_obj, account) if web_obj.present?

          # FIND OR CREATE TEMPLATE, THEN UPDATE IF APPLICABLE
          template_name = uni_hsh['template_name']
          template_obj = save_simple_obj('template', {'template_name' => template_name}) if template_name.present?
          create_obj_parent_assoc('template', template_obj, web_obj) if template_obj && web_obj

          # FIND OR CREATE PHONE, THEN UPDATE IF APPLICABLE
          phone = uni_hsh['phone']
          phone = PhoneFormatter.validate_phone(phone) if phone.present?
          phone_obj = save_simple_obj('phone', obj_hsh={'phone' => phone}) if phone.present?
          create_obj_parent_assoc('phone', phone_obj, account) if phone_obj.present?

          # FIND OR CREATE ADDRESS, THEN UPDATE IF APPLICABLE
          address_hsh = validate_hsh(Address.column_names, non_account_attributes_array.to_h)
          address_hsh = AddressFormatter.format_address_hsh(address_hsh) if address_hsh && !address_hsh.empty?
          address_obj = save_simple_obj('address', address_hsh) if address_hsh && !address_hsh.empty?
          create_obj_parent_assoc('address', address_obj, account) if address_obj

          # FIND OR CREATE WHO, THEN UPDATE IF APPLICABLE
          if uni_hsh['ip'] || uni_hsh['server1'] || uni_hsh['server2']
            who_hsh = validate_hsh(Who.column_names, non_account_attributes_array.to_h)
            who_obj = Who.find_or_create_by(who_hsh)
            who_obj.webs << web_obj if (web_obj && !who_obj.webs.include?(web_obj))
          end

        rescue StandardError => error
          puts "\n\n=== RESCUE ERROR!! ==="
          puts error.class.name
          puts error.message
          print error.backtrace.join("\n")
          binding.pry
          @rollbacks << uni_hsh
        end

      end ## end of batch iteration.
    end ## end of in_batches iteration

    @rollbacks.each { |uni_hsh| puts uni_hsh }
    # UniAccount.destroy_all

    UniAccount.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('uni_accounts')
  end

end
