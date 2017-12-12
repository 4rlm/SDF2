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

  # def initialize(model, file_name)
  #   @model = model
  #   @file_name = "#{file_name}.csv"
  #   # @file_name = "#{@model.to_s.pluralize.downcase}.csv"
  #   @dir_path = "./db/backups"
  #   FileUtils.mkdir_p(@dir_path)
  #   @file_path = "#{@dir_path}/#{@file_name}"
  # end

  def initialize
    @seeds_dir_path = "./db/csv/seeds"
    @backups_dir_path = "./db/csv/backups"

    FileUtils.mkdir_p(@seeds_dir_path)
    FileUtils.mkdir_p(@backups_dir_path)

    # @seeds_file_path = "#{@seeds_dir_path}/#{file_name}"
    # @backups_file_path = "#{@backups_dir_path}/#{file_name}"
    #

    # @dir_path = "./db/backups"
    # FileUtils.mkdir_p(@dir_path)
    # @file_path = "#{@dir_path}/#{@file_name}"
  end


end
