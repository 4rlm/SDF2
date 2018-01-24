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
    @dj_on = false
    @dj_count_limit = 10
    @workers = 4
    @obj_in_grp = 20
    @timeout = 10 ## below
    @err_id_count = 0
    @cut_off = 90.hours.ago
    @formatter = Formatter.new
    @mig = Mig.new

    @make_urlx = FALSE
  end


  def get_query

    ## Nil Sts Query ##
    query = Web.select(:id).where(url_ver_sts: nil).order("updated_at ASC").pluck(:id)

    ## Valid Sts Query ##
    val_sts_arr = ['Valid']
    query = Web.select(:id).where(url_ver_sts: val_sts_arr).where('url_ver_date < ? OR url_ver_date IS NULL', @cut_off).order("updated_at ASC").pluck(:id) if !query.any?

    ## Error Sts Query ##
    if !query.any?
      err_sts_arr = ['Error: Timeout', 'Error: Host', 'Error: TCP']
      query = Web.select(:id).where(urlx: FALSE, url_ver_sts: err_sts_arr).order("updated_at ASC").pluck(:id)
      @timeout = 60

      if query.any? && @make_urlx
        binding.pry
        ## Kill Query by updating: urlx: TRUE
        query.each { |id| web_obj = Web.find(id).update(urlx: TRUE) }
        query = [] ## reset
        @make_urlx = FALSE
      elsif query.any?
        binding.pry
        @make_urlx = TRUE
      end
    end

    print_query_stats(query)
    binding.pry
    return query
  end

  def print_query_stats(query)
    puts "\n\n===================="
    puts "@timeout: #{@timeout}\n\n"
    puts "\n\nQuery Count: #{query.count}"
  end


  ###############################################################<<<<<<<<<<<<<<<<
  def start_ver_url
    query = get_query
    # while query.any? && !@exit_program
    while query.any?
      setup_iterator(query)
      delete_fwd_web_dups ## Removes duplicates
      query = get_query
      break if !query.any?
      binding.pry
      # start_ver_url
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
      formatted_url = @formatter.format_url(web_url)
      if !formatted_url.present? ## If nil, url is bad, and ends current process.
        invalid_hsh = {urlx: TRUE, sts_code: nil, url_ver_sts: 'Invalid', url_ver_date: Time.now}
        web_obj.update(invalid_hsh)
      elsif formatted_url != web_url ## Creates fwd_web_obj, which goes to end of next queue.
        fwd_web_obj = Web.find_or_create_by(url: formatted_url)
        AssocWeb.transfer_web_associations(web_obj, fwd_web_obj)
      else  ####### CURL-BEGINS - FORMATTED URLS ONLY!! #######
        curl_hsh = start_curl(formatted_url)
        err_msg = curl_hsh[:err_msg]
        if !err_msg.present?
          update_db(web_obj, curl_hsh)
        elsif err_msg == "Error: Timeout" || err_msg == "Error: Host"
          puts "err_msg: #{err_msg}"
          web_obj.update(urlx: FALSE, url_ver_sts: err_msg, url_ver_date: Time.now)
        else
          web_obj.update(urlx: TRUE, sts_code: nil, url_ver_sts: err_msg, url_ver_date: Time.now)
        end
      end
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
    AssocWeb.transfer_web_associations(web_obj, fwd_web_obj)
  end


  def delete_fwd_web_dups
    # web_dup_count = Web.select(:url).group(:url).having("count(*) > 1").size
    dup_fwd_urls = Web.select(:url).group(:url).having("count(*) > 1").pluck(:url)
    web_hsh = {urlx: FALSE, url_ver_sts: nil, sts_code: nil, url_ver_date: nil}
    if dup_fwd_urls.present?
      puts "\n\nFound Duplicates!"
      dup_fwd_urls.each do |fwd_url|
        Web.where(fwd_url: fwd_url).each { |web_obj| web_obj.update(web_hsh) }
        Web.where(url: fwd_url).destroy_all
      end
    else
      puts "\n\nNo Duplicates!  - All Clear!\n\n"
    end
  end


  def print_curl_results(web_url, curl_url, sts_code)
    puts "=================================="
    puts "W: #{web_url}"
    puts "C: #{curl_url}"
    puts "S: #{sts_code}\n\n\n"
  end


end
