module Reporter

  # CALL: Reporter.welcome_to_reporter
  def self.welcome_to_reporter
    puts "Welcome to the Reporter Module"
    binding.pry
  end


  # DISPLAY FINAL RESULTS AFTER MIGRATION COMPLETES.
  # CALL: Reporter.migration_report
  def self.migration_report
    puts "Accounts: #{Account.all.count}"
    puts "Contacts: #{Contact.all.count}"

    puts "Webs: #{Web.all.count}"
    puts "Webings: #{Webing.all.count}"

    puts "Texts: #{Text.all.count}"
    puts "Textings: #{Texting.all.count}"

    puts "Links: #{Link.all.count}"
    puts "Linkings: #{Linking.all.count}"

    puts "Phones: #{Phone.all.count}"
    puts "Phonings: #{Phoning.all.count}"

    puts "Addresses: #{Address.all.count}"
    puts "AccountAddresses: #{AccountAddress.all.count}"

    puts "Templates: #{Template.all.count}"
    puts "Templatings: #{Templating.all.count}"

    puts "Who: #{Who.all.count}"

    puts "Job Titles: #{Title.all.count}"
    puts "Job Descriptions: #{Description.all.count}"

    puts "Whos: #{Who.all.count}"
    puts "Terms: #{Term.all.count}"
    puts "Brands: #{Brand.all.count}"
  end


end
