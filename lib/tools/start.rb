# Note: This is where to call high-level processes involving anything in the Tools Directory.

#Call: Start.method_name
class Start

  #Call: Start.mega_start
  def self.mega_start
    CsvTool.new.import_all_seed_files ## imports all seeds.
    UrlVerifier.new.start_url_verifier ## verifies urls, redirects.
  end

  ##############################
  ###### IMPORTS-EXPORTS #######
  ##############################

  # 1) CALL: Start.import_all_seed_files
  def self.import_all_seed_files
    CsvTool.new.import_all_seed_files
  end

  # 2) CALL: Start.backup_entire_db
  def self.backup_entire_db
    CsvTool.new.backup_entire_db
  end

  # 3) CALL: Start.restore_all_backups
  def self.restore_all_backups
    CsvTool.new.restore_all_backups
  end

  ##############################
  ######### VERIFIERS ##########
  ##############################

  # 4) CALL: Start.start_url_verifier
  def self.start_url_verifier
    UrlVerifier.new.start_url_verifier
  end
  ## Use with foreman start

  ##############################
  ########## FINDERS ###########
  ##############################

  # 5) CALL: Start.start_template_finder
  def self.start_template_finder
    TemplateFinder.new.start_template_finder
    ### REMEMBER TO RUN TIMEOUT QUERY ###
  end
    ## Use with foreman start

  # 6) CALL: Start.start_page_finder
  def self.start_page_finder
    PageFinder.new.start_page_finder
  end
    ## Use with foreman start

  ##############################
  ####### Google Places ########
  ##############################

  ## GP FOR ACTS -W/O- SCRAPER
  # 7) CALL: Start.start_act_goog
  def self.start_act_goog
    ActGp.new.start_act_goog
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
