# Note: This is where to call high-level processes involving anything in the Tools Directory.

#Call: Start.method_name
class Start

  ###################
  ## == IMPORTS-EXPORTS == ##
  ###################

  #CALL: Start.import_seeds
  def self.import_seeds
    CsvTool.new.import_all_seed_files
  end


  #CALL: Start.create_backups
  def self.create_backups
    CsvTool.new.backup_entire_db
  end


  #CALL: Start.restore_backups
  def self.restore_backups
    CsvTool.new.restore_all_backups
  end


  ###################
  ## == VERIFIERS == ##
  ###################


  #CALL: Start.verify_urls
  def self.verify_urls
    UrlVerifier.new.start_url_verifier
  end


  #CALL: Start.find_templates
  def self.find_templates
    TemplateFinder.new.start_template_finder
  end






end
