desc "This task is called by the Heroku scheduler add-on"


task run_all_scrapers: :environment do
  VerUrl.new.delay.start_ver_url
  FindTemp.new.delay.start_find_temp
end

task check_urls: :environment do
  VerUrl.new.delay.start_ver_url
end


task check_templates: :environment do
  FindTemp.new.delay.start_find_temp
end

# rake verify_urls
# rake check_templates
# heroku run rake verify_urls

# heroku addons:create scheduler:standard
# heroku addons:open scheduler
# heroku logs --ps scheduler.1
# heroku ps
