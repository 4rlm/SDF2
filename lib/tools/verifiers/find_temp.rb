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
    @dj_on = false ## If true, use '$ foreman start'
    # @dj_on = false ## If true, use '$ foreman start'

    @mig = Mig.new
    @timeout = 10
    @dj_count_limit = 30
    @workers = 4
    @obj_in_grp = 50
    @cut_off = 6.hours.ago
    @prior_query_count = 0
  end

  def get_query
    val_sts_arr = ['Valid', nil]
    query = Web.select(:id).
      where(url_ver_sts: 'Valid', tmp_sts: val_sts_arr).
      where('tmp_date < ? OR tmp_date IS NULL', @cut_off).
      order("updated_at ASC").
      pluck(:id)

    if query.empty?
      err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
      query = Web.select(:id).
      where(url_ver_sts: 'Valid', tmp_sts: err_sts_arr).
      order("updated_at ASC").
      pluck(:id)

      puts "\n\nQ2-Count: #{query.count}"
      binding.pry
    else
      puts "\n\nQ1-Count: #{query.count}"
      binding.pry
    end

    return query
  end

  def start_find_temp
    query = get_query
    query_count = query.count
    while query_count != @prior_query_count
      setup_iterator(query)
      @prior_query_count = query_count
      break if query_count == get_query.count
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
    url = web_obj.url
    noko_hsh = start_noko(url)
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

  def update_db(id, web_obj, new_temp, tmp_sts)
    cur_temp = web_obj.temp_name
    web_hsh = {tmp_sts: tmp_sts, temp_name: new_temp, tmp_date: Time.now}
    web_obj.update(web_hsh)
    puts "\n\n================"
    puts "cur_temp: #{cur_temp}"
    puts "new_temp: #{new_temp}"
    puts "tmp_sts: #{tmp_sts}"
    puts "-----------------------"
    puts "#{web_obj.inspect}\n\n"
  end

  # starter if (id == @last_id) ## Restart, get next batch of ids.
end


########## Original Stuff #############


  ################################
  # def get_primary_query
  #   # sts_codes = Web.where(sts_code: [200..299]).count
    # primary_query = Web.where(url_ver_sts: 'Valid', tmp_sts: nil).order("updated_at ASC").pluck(:id)
  # end

  # def get_tcp_query
  #   tcp_query = Web.where(tmp_sts: 'Error: TCP').order("updated_at ASC").pluck(:id)
  # end
  #
  # def get_timeout_query
  #   timeout_query = Web.where("tmp_sts LIKE '%timeout%'").order("updated_at ASC").pluck(:id)
  # end
  ################################
  # tmp_sts: nil, tmp_date:


  # # Call: FindTemp.new.start_find_temp
  # def start_find_temp
  #   primary_query = get_primary_query
  #   primary_query_count = primary_query.count
  #   while primary_query_count > 0
  #     setup_iterator(primary_query)
  #     break if primary_query_count == get_primary_query.count
  #     start_find_temp
  #   end
  #
  #   timeout_query = get_timeout_query
  #   timeout_query_count = timeout_query.count
  #   @timeout = 30
  #   if timeout_query_count > 0
  #     setup_iterator(timeout_query)
  #     # break if timeout_query_count == get_timeout_query.count
  #     # start_find_temp
  #   end
  #
  #   tcp_query = get_tcp_query
  #   tcp_query_count = tcp_query.count
  #   if tcp_query_count > 0
  #     setup_iterator(tcp_query)
  #     # break if tcp_query_count == get_tcp_query.count
  #     # start_find_temp
  #   end
  #
  # end
