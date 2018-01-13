# Note: This is where to call high-level processes involving anything in the Tools Directory.

#Call: Start.method_name
class Start

  ##############################
  ###### IMPORTS-EXPORTS #######
  ##############################

  # 1) CALL: Start.import_seeds
  def self.import_seeds
    CsvTool.new.import_all_seed_files
  end


  # 2) CALL: Start.create_backups
  def self.create_backups
    CsvTool.new.backup_entire_db
  end


  # 3) CALL: Start.restore_backups
  def self.restore_backups
    CsvTool.new.restore_all_backups
  end


  ##############################
  ######### VERIFIERS ##########
  ##############################


  # 4) CALL: Start.verify_urls
  def self.verify_urls
    UrlVerifier.new.start_url_verifier
  end
  ## Use with foreman start


  ##############################
  ########## FINDERS ###########
  ##############################


  # 5) CALL: Start.find_templates
  def self.find_templates
    TemplateFinder.new.start_template_finder
    ### REMEMBER TO RUN TIMEOUT QUERY ###
  end
    ## Use with foreman start


  # 6) CALL: Start.find_pages
  def self.find_pages
    PageFinder.new.start_page_finder
  end
    ## Use with foreman start


  ##############################
  ########## SCRAPERS ##########
  ##############################


  # 7) CALL: Start.scrape_acts
  def self.scrape_acts
    ActScraper.new.start_act_scraper
  end
    ## Use with foreman start


  # 8) CALL: Start.scrape_conts
  # def self.scrape_conts
  #   ContScraper.new.start_cont_scraper
  # end



end
