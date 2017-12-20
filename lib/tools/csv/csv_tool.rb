require 'csv'
require 'pry'
require 'exporter'
require 'importer'

class CsvTool
  extend ActiveSupport::Concern
  include Exporter
  include Importer
  attr_reader :file_name, :file_path

  def initialize
    @seeds_dir_path = "./db/csv/seeds"
    @backups_dir_path = "./db/csv/backups"
    FileUtils.mkdir_p(@seeds_dir_path)
    FileUtils.mkdir_p(@backups_dir_path)
  end


  #CALL: CsvTool.new.restore_all_backups
  def restore_all_backups
    db_table_list = get_db_table_list
    db_table_list_hashes = db_table_list.map do |table_name|
      { model: table_name.classify.constantize, plural_model_name: table_name.pluralize }
    end

    db_table_list_hashes.each do |hash|
      hash[:model].delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!(hash[:plural_model_name])
    end

    db_table_list_hashes.each do |hash|
      restore_backup(hash[:model], "#{hash[:plural_model_name]}.csv")
    end

    ######### Reset PK Sequence #########
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end

  end


  ### SHARED METHODS AMONGST BOTH MODULES ###


  #CALL: CsvTool.new.get_db_table_list
  def get_db_table_list
    Rails.application.eager_load!
    db_table_list = ActiveRecord::Base.descendants.map(&:name)
    removables = ['ApplicationRecord', 'UniAccount', 'UniContact', 'UniWeb', 'Delayed::Backend::ActiveRecord::Job']
    removables.each { |table| db_table_list.delete(table) }
    db_table_list = db_table_list.sort_by(&:length)
    return db_table_list
  end


  def validate_hash(cols, hash)
    # cols.map!(&:to_sym)
    keys = hash.keys
    keys.each { |key| hash.delete(key) if !cols.include?(key) }
    return hash
  end


  def parse_csv
    counter = 0
    error_row_numbers = []
    @clean_csv_hashes = []
    @headers = []
    @rows = []

    File.open(@file_path).each do |line|
      begin
        line_1 = line&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
        line_2 = force_utf_encoding(line_1) ## Removes non-utf8 chars.

        CSV.parse(line_2) do |row|
          row = row.collect { |x| x.try(:strip) } ## Strips white space from each el in row array.
          
          if counter > 0
            @clean_csv_hashes << row_to_hash(row)
            @rows << row
          else
            @headers = row
          end
          counter += 1
        end
      rescue => er
        error_row_numbers << {"#{counter}": "#{er.message}"}
        counter += 1
        next
      end
    end

    error_report(error_row_numbers)
    # return @clean_csv_hashes
  end


  def error_report(error_row_numbers)
    puts "\nCSV data ready to import.\nCSV Errors Found: #{error_row_numbers.length}\nRows containing errors (if any) will be skipped.\nErrors on the lines listed below (if any):"
    error_row_numbers.each_with_index { |hash, i| puts "#{i+1}) Row #{hash.keys[0]}: #{hash.values[0]}." }
  end

  def row_to_hash(row)
    h = Hash[@headers.zip(row)]
    h.symbolize_keys
  end


  def completion_msg(model, file_name)
    Reporter.migration_report
    puts "\n\n== Completed Import: #{file_name} to #{model} table. ==\n\n"
  end

  def force_utf_encoding(text)
    # text = "Ã¥ÃŠÃ¥Â©team auto solutions"
    # text = "Ã¥ÃŠÃ¥ÃŠÃ¥ÃŠour staff"
    clean_text = text.delete("^\u{0000}-\u{007F}")
    clean_text = clean_text.gsub(/\s+/, ' ')

    return clean_text
  end


end
