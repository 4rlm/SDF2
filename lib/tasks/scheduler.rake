desc "This task is called by the Heroku scheduler add-on"

task :verify_urls => :environment do
  VerUrl.new.start_ver_url
end

# rake verify_urls
