# Note: This is where to call high-level processes involving anything in the Tools Directory.

#Call: Run.method_name
class Run

  ###################
  ## == EXPORTS == ##
  ###################


  #CALL: Run.create_backups
  def self.create_backups
    CsvTool.new.backup_entire_db
  end


  ###################
  ## == IMPORTS == ##
  ###################


  #CALL: Run.restore_backups
  def self.restore_backups
    CsvTool.new.restore_all_backups
  end

  #CALL: Run.import_seeds
  def self.import_seeds
    CsvTool.new.import_all_seed_files
  end


  ###################
  ## == VERIFIERS == ##
  ###################


  #CALL: Run.verify_urls
  def self.verify_urls
    UrlVerifier.new.start_url_verifier
  end


  #CALL: Run.find_templates
  def self.find_templates
    binding.pry
    TemplateFinder.new.start_template_finder
  end






end
