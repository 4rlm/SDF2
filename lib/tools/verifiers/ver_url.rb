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
    @dj_on = true
    @dj_count_limit = 5
    @dj_workers = 4
    @obj_in_grp = 20
    @dj_refresh_interval = 10
    @db_timeout_limit = 60
    @cut_off = 24.hours.ago
    @formatter = Formatter.new
    @mig = Mig.new
  end

  def get_query
    ## Valid Sts Query ##
    val_sts_arr = ['Valid', nil]
    query = Web.select(:id)
      .where(url_sts: val_sts_arr)
      .where('url_date < ? OR url_date IS NULL', @cut_off)
      .order("id ASC").pluck(:id)

    ## Error Sts Query ##
    err_sts_arr = ['Error: Timeout', 'Error: Host', 'Error: TCP']
    query = Web.select(:id)
      .where(url_sts: err_sts_arr)
      .where('timeout < ?', @db_timeout_limit)
      .order("timeout DESC")
      .pluck(:id) if !query.any?

    puts "\n\nQuery Count: #{query.count}"
    sleep(1)
    # binding.pry
    return query
  end

  def start_ver_url
    query = get_query
    while query.any?
      setup_iterator(query)
      query = get_query
      break if !query.any?
    end
  end

  def setup_iterator(query)
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
    @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }
  end

  #Call: VerUrl.new.start_ver_url
  def template_starter(id)
    web = Web.find(id)
    web_url = web.url
    db_timeout = web.timeout
    db_timeout == 0 ? timeout = @dj_refresh_interval : timeout = (db_timeout * 3)
    puts "timeout: #{timeout}"

    formatted_url = @formatter.format_url(web_url)
    if !formatted_url.present?
      web.update(url_sts_code: nil, url_sts: 'Invalid', url_date: Time.now, timeout: timeout)
      return
    end

    if formatted_url != web_url
      fwd_web_obj = Web.find_by(url: formatted_url)
      if fwd_web_obj.present?
        web.update(url_sts: 'FWD', url_date: Time.now, timeout: 0)
        fwd_web_obj.update(url_sts: 'Valid', url_date: Time.now, timeout: 0)
        AssocWeb.transfer_web_associations(web, fwd_web_obj)
      end
    end

    ####### CURL-BEGINS - FORMATTED URLS ONLY!! #######
    #Call: VerUrl.new.start_ver_url
    if formatted_url.present?
      curl_hsh = start_curl(formatted_url, timeout)
      err_msg = curl_hsh[:err_msg]

      if !err_msg.present?
        update_db(web, curl_hsh)
      elsif err_msg == "Error: Timeout" || err_msg == "Error: Host"
        puts "err_msg: #{err_msg}"
        web.update(url_sts: err_msg, url_date: Time.now, timeout: timeout)
      else
        web.update(url_sts_code: nil, url_sts: err_msg, url_date: Time.now, timeout: 0)
      end

    end
  end

  def update_db(web, curl_hsh)
    web_url = web.url
    url_sts_code = curl_hsh[:url_sts_code]
    curl_url = curl_hsh[:curl_url]
    print_curl_results(web_url, curl_url, url_sts_code)

    fwd_web_obj = Web.find_by(url: curl_url) if (curl_url != web_url)
    if fwd_web_obj.present?
      web.update(url_sts: 'FWD', url_date: Time.now, timeout: 0)
      fwd_web_obj.update(url_sts: 'Valid', url_date: Time.now, timeout: 0)
      AssocWeb.transfer_web_associations(web, fwd_web_obj)
    else
      web.update(url: curl_url, url_sts: 'Valid', url_sts_code: url_sts_code, url_date: Time.now, timeout: 0)
    end
  end

  def print_curl_results(web_url, curl_url, url_sts_code)
    puts "=================================="
    puts "W: #{web_url}"
    puts "C: #{curl_url}"
    puts "S: #{url_sts_code}\n\n\n"
  end

end
