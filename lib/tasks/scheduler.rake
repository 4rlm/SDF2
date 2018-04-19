desc "This task is called by the Heroku scheduler add-on"


task run_all_scrapers: :environment do
  Start.delay.run_all_scrapers
end

task check_urls: :environment do
  VerUrl.new.delay.start_ver_url
end


task check_templates: :environment do
  FindTemp.new.delay.start_find_temp
end

# rake verify_urls
# rake run_all_scrapers
# heroku run rake run_all_scrapers
# heroku run rake jobs:clear

# heroku addons:create scheduler:standard
# heroku addons:open scheduler
# heroku logs --ps scheduler.1
# heroku ps
