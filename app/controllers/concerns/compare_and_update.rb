module CompareAndUpdate
  extend ActiveSupport::Concern

  ## Description: Dynamically compares values from two different tables, then updates the target attribute if it fits criteria.
  ###### Usage at Bottom ######

  def start_compare_and_update
    @update_hash = {}
    extract_field_sets
    update_db
  end

  def extract_field_sets
    @field_sets.each { |item| compare_fields(item[0], item[1]) }
  end

  def extract_manual_update_sets
    @manual_update_sets.each do |item|
      @update_hash[item[0].to_sym] = item[1]
    end
  end

  def filter_criteria(target_attr)
    rule_status = false
    if @criteria
      @criteria.each{ |rule| rule_status = true if target_attr.include?(rule) }
    end
    rule_status
  end

  def compare_fields(target_field, compare_field)
    target_attr = @target_row.send(target_field)
    compare_attr = @compare_row.send(compare_field)

    if compare_attr.present? && target_attr != compare_attr
      if target_attr == nil || filter_criteria(target_attr)
        puts "\n#{target_field}: #{target_attr}\n#{compare_field}: #{compare_attr}"
        @update_hash[target_field.to_sym] = compare_attr
      elsif @criteria == nil
        puts "\n#{target_field}: #{target_attr}\n#{compare_field}: #{compare_attr}"
        @update_hash[target_field.to_sym] = compare_attr
      end
    end

  end

  def update_db
    if @update_hash.present?
      extract_manual_update_sets
      # puts "@target_row.update_attributes(#{@update_hash})"
      @target_row.update_attributes(@update_hash)
      # binding.pry
    end
  end

end



###### Usage ######

## Usage: Must copy and paste into parent class:
  ## 1) 'include CompareAndUpdate'
  ## 2) Entire method below.
  ## Example: lib/servicers/geo_mega_migrator.rb


  # def configure_compare_and_update(target_row, compare_row) #=> via CompareAndUpdate module
  #   @criteria = ['Meta Result', 'MS Result', 'Error', '|']
  #   @target_row = target_row
  #   @compare_row = compare_row
  #
  #   @field_sets = [
  #     [:clean_url, :url],
  #     [:acct_name, :geo_acct_name],
  #     [:acct_pin, :geo_acct_pin],
  #     [:full_addr, :geo_full_addr],
  #     [:street, :street],
  #     [:city, :city],
  #     [:state, :state_code],
  #     [:zip, :postal_code]
  #   ]
  #
  #   start_compare_and_update #=> via CompareAndUpdate module
  # end
