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
    @workers = 4
    @obj_in_grp = 20
    @timeout = 10 ## below
    @cut_off = 30.days.ago
    # @cut_off = 1.minute.ago
    @make_urlx = FALSE
    @formatter = Formatter.new
    @mig = Mig.new
  end


  def get_query
    ## Nil Sts Query ##
    query = Act.select(:id).where(actx: FALSE, gp_sts: 'Valid', url_sts: nil).order("updated_at ASC").pluck(:id)

    ## Valid Sts Query ##
    val_sts_arr = ['Valid']
    query = Act.select(:id).where(actx: FALSE, gp_sts: 'Valid', url_sts: val_sts_arr).where('url_date < ? OR url_date IS NULL', @cut_off).order("updated_at ASC").pluck(:id) if !query.any?

    ## Error Sts Query ##
    if !query.any?
      err_sts_arr = ['Error: Timeout', 'Error: Host', 'Error: TCP']
      query = Act.select(:id).where(actx: FALSE, gp_sts: 'Valid', url_sts: err_sts_arr).order("updated_at ASC").pluck(:id)
      @timeout = 30

      if query.any? && @make_urlx
        query.each { |id| act_obj = Act.find(id).update(urlx: TRUE) }
        query = [] ## reset
        @make_urlx = FALSE
      elsif query.any?
        @make_urlx = TRUE
      end
    end

    print_query_stats(query)
    return query
  end


  def print_query_stats(query)
    puts "\n\n===================="
    puts "@timeout: #{@timeout}\n\n"
    puts "\n\nQuery Count: #{query.count}"
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


  def template_starter(id)
    act_obj = Act.find(id)
    web_url = act_obj.url
    formatted_url = @formatter.format_url(web_url)
    if !formatted_url.present?
      ## If nil, url is bad, and ends current process.
      invalid_hsh = {urlx: TRUE, url_sts_code: nil, url_sts: 'Invalid', url_date: Time.now}
      act_obj.update(invalid_hsh)
      return ## Stop Here.  Don't run Curl Below.
    elsif formatted_url != web_url
      ## These may continue to run Curl.
      act_obj.update(url: formatted_url)
    end

    ####### CURL-BEGINS - FORMATTED URLS ONLY!! #######
    if formatted_url.present?
      curl_hsh = start_curl(formatted_url)
      err_msg = curl_hsh[:err_msg]
      if !err_msg.present?
        update_db(act_obj, curl_hsh)
      elsif err_msg == "Error: Timeout" || err_msg == "Error: Host"
        puts "err_msg: #{err_msg}"
        act_obj.update(urlx: FALSE, url_sts: err_msg, url_date: Time.now)
      else
        act_obj.update(urlx: TRUE, url_sts_code: nil, url_sts: err_msg, url_date: Time.now)
      end
    end
  end


  def update_db(act_obj, curl_hsh)
    web_url = act_obj.url
    url_sts_code = curl_hsh[:url_sts_code]
    curl_url = curl_hsh[:curl_url]
    print_curl_results(web_url, curl_url, url_sts_code)
    web_hsh = {urlx: FALSE, url: curl_url, url_sts: 'Valid', url_sts_code: url_sts_code, url_date: Time.now}
    act_obj.update(web_hsh)
  end

  def print_curl_results(web_url, curl_url, url_sts_code)
    puts "=================================="
    puts "W: #{web_url}"
    puts "C: #{curl_url}"
    puts "S: #{url_sts_code}\n\n\n"
  end

end
