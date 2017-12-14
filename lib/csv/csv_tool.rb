# Notes:
# 1) CsvTool class calls CsvToolMod module.  Both files work together.
# 2) Note: Ensure config/application.rb extends autoload to concerns.

## Call: CsvTool.new(Account).backup_csv
## Call: CsvTool.new(Account).download_csv

## Call: CsvTool.new(Account).import_csv
## Call: CsvTool.new(Account).iterate_csv
###########################################

require 'csv'
require 'pry'

class CsvTool
  extend ActiveSupport::Concern
  include CsvToolMod::Export
  include CsvToolMod::Import
  attr_reader :file_name, :file_path

  def initialize
    @seeds_dir_path = "./db/csv/seeds"
    @backups_dir_path = "./db/csv/backups"

    FileUtils.mkdir_p(@seeds_dir_path)
    FileUtils.mkdir_p(@backups_dir_path)
  end

end
