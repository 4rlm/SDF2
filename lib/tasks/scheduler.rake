desc "This task is called by the Heroku scheduler add-on"

#CALL: heroku run rake run_all_scrapers
task run_all_scrapers: :environment do
  Start.delay.run_all_scrapers
end


#CALL: heroku run rake get_process_sts
task get_process_sts: :environment do
  Start.get_process_sts
end




# rake verify_urls
# rake run_all_scrapers
# heroku run rake run_all_scrapers
# heroku run rake jobs:clear

# heroku addons:create scheduler:standard
# heroku addons:open scheduler
# heroku logs --ps scheduler.1
# heroku ps
