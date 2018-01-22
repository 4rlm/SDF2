# Call: VerUrl.new.start_ver_url
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'assoc_web'
require 'curler'

class VerUrl
  include IterQuery
  include Curler
  include AssocWeb

  def initialize
    @dj_on = false ## If true, use '$ foreman start'
    @formatter = Formatter.new
    @mig = Mig.new
    @timeout = 20
    @dj_count_limit = 30
    @workers = 4
    @obj_in_grp = 50
    @cut_off = 48.hours.ago
    @prior_query_count = 0
  end

  def get_query
    val_sts_arr = ['Valid', nil]
    query = Web.select(:id).
      where(url_ver_sts: val_sts_arr).
      where('url_ver_date < ? OR url_ver_date IS NULL', @cut_off).
      order("updated_at ASC").
      pluck(:id)

    if query.empty?
      err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
      query = Web.select(:id).
      where(url_ver_sts: err_sts_arr).
      order("updated_at ASC").
      pluck(:id)
      @timeout *= 3
      puts "\n\nQ2-Count: #{query.count}"
    else
      puts "\n\nQ1-Count: #{query.count}"
    end

    return query
  end


  def start_ver_url
    query = get_query
    query_count = query.count
    while query_count != @prior_query_count
      setup_iterator(query)
      @prior_query_count = query_count
      break if query_count == get_query.count
      start_ver_url
    end
  end

  def setup_iterator(query)
    # @query_count = query.count
    # (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
    # @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }

    # query.each { |id| delay.template_starter(id) }
    query.each { |id| template_starter(id) }
  end

  def template_starter(id)
    web_obj = Web.find(id)
    binding.pry
    # web_obj = Web.lock.find(id)

    web_url = web_obj.url
    formatted_url = @formatter.format_url(web_url)

    if !formatted_url.present?
      invalid_hsh = {urlx: TRUE, sts_code: nil, url_ver_sts: 'Invalid', url_ver_date: Time.now}
      web_obj.update(invalid_hsh)
      return ## PROCESS STOPS HERE IF FORMATTED URL IS NIL - NEVER GOES TO CURL!
    elsif formatted_url != web_url
      fwd_web_obj = save_fwd_web_obj(web_obj, formatted_url)
      ## Important - Switch, before going to CURL!!!
      web_obj = fwd_web_obj
      web_url = fwd_web_obj.url
    end

    ####### CURL-BEGINS - FORMATTED URLS ONLY!! #######
    curl_hsh = start_curl(formatted_url)
    err_msg = curl_hsh[:err_msg]

    if !err_msg.present?
      update_db(web_obj, curl_hsh)
    elsif err_msg == "Error: Timeout" || err_msg == "Error: Host"
      web_obj.update(urlx: FALSE, url_ver_sts: err_msg, url_ver_date: Time.now)
    else
      web_obj.update(urlx: TRUE, sts_code: nil, url_ver_sts: err_msg, url_ver_date: Time.now)
    end
  end


  def update_db(web_obj, curl_hsh)
    web_url = web_obj.url
    sts_code = curl_hsh[:sts_code]
    curl_url = curl_hsh[:curl_url]
    print_curl_results(web_url, curl_url, sts_code)
    web_hsh = {urlx: FALSE, url_ver_sts: 'Valid', sts_code: sts_code, url_ver_date: Time.now}
    curl_url == web_url ? web_obj.update(web_hsh) : save_fwd_web_obj(web_obj, curl_url)
    # starter if (id == @last_id) ## Restart, get next batch of ids.
  end


  def save_fwd_web_obj(web_obj, fwd_url)
    fwd_web_obj = Web.find_or_create_by(url: fwd_url)
    # fwd_web_obj = @mig.save_simp_obj('web', {url: fwd_url})
    fwd_web_obj = AssocWeb.transfer_web_associations(web_obj, fwd_web_obj)
    return fwd_web_obj
  end

  def print_curl_results(web_url, curl_url, sts_code)
    puts "=================================="
    puts "W: #{web_url}"
    puts "C: #{curl_url}"
    puts "S: #{sts_code}\n\n\n"
  end


end
