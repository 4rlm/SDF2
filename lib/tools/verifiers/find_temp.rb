# Call: FindTemp.new.start_find_temp
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'curler'
require 'noko'

class FindTemp
  include IterQuery
  include Noko

  def initialize
    @dj_on = false
    @dj_count_limit = 30
    @workers = 4
    @obj_in_grp = 50
    @timeout = 10
    @count = 0
    @cut_off = 48.hours.ago
    @prior_query_count = 0

    @mig = Mig.new
  end

  def get_query
    @count += 1
    @timeout *= @count
    puts "\n\n===================="
    # delete_fwd_web_dups ## Removes duplicates
    puts "@count: #{@count}"
    puts "@timeout: #{@timeout}\n\n"


    val_sts_arr = ['Valid', nil]
    val_query = Web.select(:id).
      where(url_ver_sts: 'Valid', tmp_sts: val_sts_arr).
      where('tmp_date < ? OR tmp_date IS NULL', @cut_off).
      order("updated_at ASC").
      pluck(:id)


    err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
    err_query = Web.select(:id).
      where(url_ver_sts: 'Valid', tmp_sts: err_sts_arr).
      order("updated_at ASC").
      pluck(:id)

    query = (val_query + err_query)&.uniq
    puts "\n\nQ1-Count: #{query.count}"
    return query
  end

  def start_find_temp
    query = get_query
    query_count = query.count
    while query_count != @prior_query_count
      setup_iterator(query)
      @prior_query_count = query_count
      break if (query_count == get_query.count) || @count > 4
      start_find_temp
    end
  end

  def setup_iterator(query)
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
    @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }
  end

  def template_starter(id)
    web_obj = Web.find(id)

    if web_obj.present?
      web_url = web_obj.url
      noko_hsh = start_noko(web_url)
      page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]

      if err_msg.present?
        puts err_msg
        tmp_sts = err_msg
        new_temp = 'Error: Search'
      end

      if page.present?
        new_temp = Term.where(category: "find_temp").where(sub_category: "at_css").select { |term| term.response_term if page&.at_css('html')&.text&.include?(term.criteria_term) }&.first&.response_term
        new_temp.present? ? tmp_sts = 'Valid' : tmp_sts = 'Unidentified'
      end

      update_db(id, web_obj, new_temp, tmp_sts)
    end
  end

  def update_db(id, web_obj, new_temp, tmp_sts)
    cur_temp = web_obj.temp_name
    web_hsh = {tmp_sts: tmp_sts, temp_name: new_temp, tmp_date: Time.now}
    web_obj.update(web_hsh)
    print_temp_results(web_obj, cur_temp, new_temp, tmp_sts)
  end


  def print_temp_results(web_obj, cur_temp, new_temp, tmp_sts)
    puts "\n\n================"
    puts "cur_temp: #{cur_temp}"
    puts "new_temp: #{new_temp}"
    puts "tmp_sts: #{tmp_sts}"
    puts "-----------------------"
    puts "#{web_obj.inspect}\n\n"
  end

end
