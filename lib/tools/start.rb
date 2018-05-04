# Note: This is where to call high-level processes involving anything in the Tools Directory.

class Start

  #CALL: heroku run rake run_all_scrapers
  #CALL: Start.run_all_scrapers
  def self.run_all_scrapers
    priority_jobs
    Start.get_process_sts
    VerUrl.new.start_ver_url
    FindTemp.new.start_find_temp
    FindPage.new.start_find_page
    GpStart.new.start_gp_act
    FindBrand.new.start_find_brand
    ContScraper.new.start_cont_scraper
  end

  #CALL: Start.priority_jobs
  def self.priority_jobs
    top_priorities = Delayed::Job.where('priority <= 1')
    low_priorities = Delayed::Job.where('priority = 0')
    top_priorities&.each { |job| job.invoke_job }
    low_priorities.destroy_all if top_priorities.any? && low_priorities.any?
  end


  # Moved to Application Model
  # #CALL: Start.priority_jobs
  # def self.priority_jobs
  #   priorities = Delayed::Job.where('priority <= 1')
  #   priorities.each { |job| job.invoke_job }
  # end

  #CALL: Start.url_equals_fwd_url
  # def self.url_equals_fwd_url
  #   webs = Web.where(url_sts: 'FWD')
  #   dirty_webs = webs.map { |web| web if web.url == web.fwd_url }
  #   dirty_webs.compact!
  #   dirty_web_ids = dirty_webs.map(&:id)
  #   same_ids = dirty_webs.map { |web| web.id if web.id == web.fwd_url_id }
  #   same_ids.compact!
  #
  #   webs = Web.where(id: [same_ids])
  #   webs.update_all(url_sts: 'Valid', fwd_url: nil, fwd_url_id: nil)
  # end



  #Call: Start.get_process_sts
  def self.get_process_sts
    process_sts_hsh = {
      ver_url: VerUrl.new.get_query.count,
      find_temp: FindTemp.new.get_query.count,
      find_page: FindPage.new.get_query.count,
      gp: GpStart.new.get_query.count,
      find_brand: FindBrand.new.get_query.count,
      cont_scraper: ContScraper.new.get_query.count,

      url_total: Web.where(url_sts: 'Valid').count,
      temp_total: Web.where(temp_sts: 'Valid').count,
      page_total: Web.where(page_sts: 'Valid').count,
      gp_total: Act.where(gp_sts: 'Valid').count,
      brand_total: Web.where(brand_sts: 'Valid').count,
      cont_total: Web.where(cs_sts: 'Valid').count
    }

    ProcessStatus.find_or_create_by(id: 1).update(process_sts_hsh)
  end

  #Call: Start.mega_start
  def self.mega_start
    ServCsvTool.new.import_all_seed_files ## imports all seeds.
    VerUrl.new.start_ver_url ## verifies urls, redirects.
  end


  ##############################
  ###### IMPORTS-EXPORTS #######
  ##############################

  # 1) CALL: Start.import_all_seed_files
  def self.import_all_seed_files
    ServCsvTool.new.import_all_seed_files
  end

  # 2) CALL: Start.backup_entire_db
  def self.backup_entire_db
    ServCsvTool.new.backup_entire_db
  end

  # Backup PG
  # $ pg_dump -U postgres -F t sdf2_development > db/csv/pg_backups/sdf2_development.psql
  # $ pg_dump -F c -v -U postgres -h localhost sdf2_development -f db/csv/pg_backups/sdf2_development.tar

  # 3) CALL: Start.restore_all_backups
  def self.restore_all_backups
    ServCsvTool.new.restore_all_backups
  end

  ##############################
  ######### VERIFIERS ##########
  ##############################

  # 4) CALL: Start.start_ver_url
  def self.start_ver_url
    VerUrl.new.start_ver_url
  end
  ## Use with foreman start

  ##############################
  ########## FINDERS ###########
  ##############################

  # 5) CALL: Start.start_find_temp
  def self.start_find_temp
    FindTemp.new.start_find_temp
    ### REMEMBER TO RUN TIMEOUT QUERY ###
  end
    ## Use with foreman start

  # 6) CALL: Start.start_find_page
  def self.start_find_page
    FindPage.new.start_find_page
  end
    ## Use with foreman start

  ##############################
  ####### Google Places ########
  ##############################

  ## GP FOR ACTS -W/O- SCRAPER
  # 7) CALL: Start.start_act_goog
  def self.start_act_goog
    GpAct.new.start_act_goog
  end

  ## GP FOR ACTS -AND- SCRAPER
  # 8) CALL: Start.start_act_scraper
  def self.start_act_scraper
    ActScraper.new.start_act_scraper
  end

  ################################
  ### CONT-SCRAPER (w/out GP) ####
  ################################

  # 8) CALL: Start.start_cont_scraper
  # def self.start_cont_scraper
  #   ContScraper.new.start_cont_scraper
  # end

  #######################################
end
