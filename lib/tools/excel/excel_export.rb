module ExcelExport


  def action_name
    binding.pry
    @brands = Brand.all
    respond_to do |format|
      format.xlsx
    end
    binding.pry
  end

# CALL: ExcelTool.new.exporty
  def exporty
    # excel_file = "test_small.xlsx"
    # excel_path_file = "#{@excel_path}/#{excel_file}"

    # Brand id: nil, brand_name: nil, dealer_type: nil>

    action_name
    binding.pry

    wb = xlsx_package.workbook
    binding.pry
    wb.add_worksheet(name: "Buttons") do |sheet|
      @brands.each do |button|
        sheet.add_row [button.name, button.category, button.price]
      end
    end



    binding.pry
  end



  # # CALL: ExcelTool.new.backup_entire_db
  # def backup_entire_db
  #   # db_table_list = ["Link", "Linking", "Text", "Texting"]
  #   db_table_list = get_db_table_list
  #
  #   db_table_list.each do |table_name|
  #     model = table_name.constantize
  #     file_name = "#{table_name.pluralize}.Excel"
  #     ExcelTool.new.backup_Excel(model, file_name)
  #   end
  # end
  #
  #
  # #CALL: ExcelTool.new.backup_Excel(User, 'Users.Excel')
  #
  # #CALL: ExcelTool.new.backup_Excel(Tally, 'Tallies.Excel')
  # #CALL: ExcelTool.new.backup_Excel(Dealer, 'Dealers.Excel')
  # #CALL: ExcelTool.new.backup_Excel(Crma, 'Crmas.Excel')
  # #CALL: ExcelTool.new.backup_Excel(Crmc, 'Crmcs.Excel')
  # def backup_Excel(model, file_name)
  #   backups_file_path = "#{@backups_dir_path}/#{file_name}"
  #   Excel.open(backups_file_path, "wb") do |Excel|
  #     Excel << model.attribute_names
  #     model.all.each { |r| Excel << r.attributes.values }
  #   end
  # end
  #
  #
  # def download_Excel
  #   Excel.generate do |Excel|
  #     Excel << @model.attribute_names
  #     @model.all.each { |r| Excel << r.attributes.values }
  #   end
  # end
  #

end
