## Note: CsvClientTool extends class methods and provides client users ability to generate csv from views.  It is NOT associated with CsvServTool, CsvServExport, nor CsvServImport, which are server side developer tools accessed via CLI.

module CsvClientTool
  extend ActiveSupport::Concern

  module ClassMethods
    # ===== Export CSV =====
    def to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |obj|
          csv << obj.attributes.values_at(*column_names)
        end
      end
    end
  end


  ## CALL: Web.new.greeter
  def greeter
    puts "Hi"
  end


end
