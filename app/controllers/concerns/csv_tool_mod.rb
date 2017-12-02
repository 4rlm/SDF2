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

module CsvToolMod
  extend ActiveSupport::Concern

  module Export
    def backup_csv
      CSV.open(@file_path, "wb") do |csv|
        csv << @model.attribute_names
        @model.all.each { |r| csv << r.attributes.values }
      end
    end

    def download_csv
      CSV.generate do |csv|
        csv << @model.attribute_names
        @model.all.each { |r| csv << r.attributes.values }
      end
    end

  end


  module Import

    def import_csv

      # CSV.foreach(@file_path, headers: true, skip_blanks: true) do |row|
      CSV.foreach(@file_path, encoding: 'windows-1252:utf-8', headers: true, skip_blanks: true) do |row|
        valid_hash = validate_hash(@model.column_names, row.to_hash)

        begin
          if obj = @model.find_by(id: valid_hash["id"])
            @model.record_timestamps = false
            obj.update_attributes(valid_hash)
          else
            @model.record_timestamps = true
            @model.create!(valid_hash)
          end
        rescue
          puts "\n\nDuplicate Data Error\n\n"
        end

      end
    end

    def validate_hash(cols, hash)
      keys = hash.keys
      keys.each do |key|
        if !cols.include?(key)
          hash.delete(key)
        end
      end
      hash
    end

    # options = {
    #   headers: true,
    #   skip_blanks: true,
    #   col_sep: true,
    #   skip_lines: /å/
    # }

    # CSV.foreach(@file_path, options) do |row|
    #   puts counter
    #   counter+=1
    #   @csv_hashes << row.to_hash.symbolize_keys
    # end

    # call: CsvToolParser.new.import_urls
    def iterate_csv
      puts "\n\nImporting CSV.  This might take a few minutes ..."
      @csv_hashes = []
      # CSV.foreach(@file_path, headers: true, skip_blanks: true) do |row|
      # CSV.foreach(@file_path, encoding: "UTF-32BE:UTF-8", headers: true, skip_blanks: true) do |row|
      CSV.foreach(@file_path, encoding: 'windows-1252:utf-8', headers: true, skip_blanks: true) do |row|
        @csv_hashes << row.to_hash.symbolize_keys
      end

      @csv_hashes
    end

    def iterate_csv_w_error_report
      puts "\n\nImporting CSV.  This might take a few minutes ..."

      @csv_hashes = []
      counter = 0
      error_row_numbers = []
      @headers = []
      File.open(@file_path).each do |line|
        begin
          CSV.parse(line) do |row|
            counter > 0 ? @csv_hashes << row_to_hash(row) : @headers = row
            counter += 1
          end
        rescue => er
          error_row_numbers << {"#{counter}": "#{er.message}"}
          counter += 1
          next
        end

      end
      error_report(error_row_numbers)
      @csv_hashes
    end

    # call: CsvToolParser.new.import_urls
    def error_report(error_row_numbers)
      puts "\nCSV data successfully imported.\nBut #{error_row_numbers.length} rows were skipped due to the following errors on the lines listed below:\n\n"

      error_row_numbers.each_with_index { |hash, i| puts "#{i+1}) Row #{hash.keys[0]}: #{hash.values[0]}." }
    end

    def row_to_hash(row)
      h = Hash[@headers.zip(row)]
      h.symbolize_keys
    end




    ###### ORIGINAL BELOW ########
    # def import_csv
    #   upload_csv
    #   @csv_hashes.each do |valid_hash|
    #     begin
    #       if obj = @model.find_by(id: valid_hash["id"])
    #         @model.record_timestamps = false
    #         obj.update_attributes(valid_hash)
    #       else
    #         @model.record_timestamps = true
    #         @model.create!(valid_hash)
    #       end
    #     rescue
    #       puts "\n\nDuplicate Data Error\n\n"
    #     end
    #
    #   end
    # end
    #
    # def iterate_csv
    #   upload_csv
    #   return @csv_hashes
    # end
    #
    #
    # def upload_csv
    #   @csv_hashes = []
    #
    #   CSV.foreach(@file_path, headers: true, skip_blanks: true) do |row|
    #     valid_hash = validate_hash(@model.column_names, row.to_hash)
    #     @csv_hashes << valid_hash
    #   end
    #
    #   @csv_hashes
    # end

######################

  end

end
