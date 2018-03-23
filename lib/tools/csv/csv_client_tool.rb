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


    ## CALL: Web.new.greeter
    # def to_csv_getter
    #   binding.pry
    #   puts "Hi"
    #   CsvServTool.new.export_web_acts('query')
    # end







    ###########################################################
    ## FILTERED COLS: SAVES CSV, NOT GENERATE!
    ## PERFECT! - INCLUDES [WEB, BRANDS, ACTS]!
    ## CALL: CsvServTool.new.export_web_acts('query')
    def web_acts_to_csv(arr)
      binding.pry
      # all = Web.where(cs_sts: 'Valid')[-5..-1] ## Just for testing - Query should be passed in.

      file_name = "web_acts_#{Time.now.strftime("%Y%m%d%I%M%S")}.csv"
      path_and_file = "./public/downloads/#{file_name}"

      web_cols = %w(id url fwd_url url_sts cop temp_name cs_sts created_at web_changed wx_date)
      brand_cols = %w(brand_name)
      act_cols = %w(act_name gp_id gp_sts lat lon street city state zip phone act_changed adr_changed ax_date)

      # CSV.generate(options) do |csv|
      CSV.open(path_and_file, "wb") do |csv|
        csv.add_row(web_cols + brand_cols + act_cols)

        Web.where(id: arr).each do |web|
          values = web.attributes.slice(*web_cols).values
          values << web.brands&.map { |brand| brand&.brand_name }&.sort&.uniq&.join(', ')

          if web.acts.any?
            web.acts.each do |act|
              csv.add_row(values + act.attributes.slice(*act_cols).values)
            end
          else
            csv.add_row(values)
          end
        end
      end
    end












  end

end
