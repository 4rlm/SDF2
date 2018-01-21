# Call: UrlVerifier.new.start_url_verifier

require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'delayed_job'
require 'curb'
require 'timeout'
require 'net/ping'
# require 'final_fwd_url'
require 'complex_query_iterator'
require 'web_associator'
require 'curler'
require 'net/ping'
# require 'https'
require 'openssl'
require "net/http"
# %w{complex_query_iterator final_fwd_url}.each { |x| require x }

######### Delayed Job #########
# $ rake jobs:clear

class UrlVerifier
  include Curler #=> concerns/curler.rb
  include ComplexQueryIterator
  include WebAssociator

  def initialize
    @formatter = Formatter.new
    @migrator = Migrator.new
    ### for ComplexQueryIterator ###
    @timeout = 10
    @dj_count_limit = 30 #=> Num allowed before releasing next batch.
    @workers = 4 #=> Divide format_query_results into groups of x.
    ### for UrlVerifier ###
    @obj_in_grp = 50
    @cut_off = 6.hours.ago

    ## Breaks while looping if number doesn't change after each round.
    @prior_host_q_count = 0
    @prior_timeout_q_count = 0
  end

  ################################
  def get_primary_q
    query = Web.select(:id).where(urlx: FALSE).where('url_ver_date < ? OR url_ver_date IS NULL', @cut_off).order("updated_at ASC").pluck(:id)
  end

  # def get_tcp_q
  def get_host_q
    query = Web.select(:id).where(url_ver_sts: 'Error: Host').order("updated_at ASC").pluck(:id)
  end

  def get_timeout_q
    query = Web.select(:id).where("url_ver_sts LIKE '%timeout%'").order("updated_at ASC").pluck(:id)
  end
  ################################


  # Call: UrlVerifier.new.start_url_verifier
  def start_url_verifier

    ### RUN PRIMARY QUERY ###
    primary_q = get_primary_q
    primary_q_count = primary_q.count
    while primary_q_count > 0
      setup_iterator(primary_q)
      break if primary_q_count == get_primary_q.count
      start_template_finder
    end

    ### RUN HOST ERROR QUERY ###
    host_q = get_host_q
    host_q_count = host_q.count
    setup_iterator(host_q) if host_q_count != @prior_host_q_count
    @prior_host_q_count = host_q_count ## Sets current count to compare for next round.

    ### RUN TIMEOUT QUERY ###
    timeout_q = get_timeout_q
    timeout_q_count = timeout_q.count
    @timeout = 30
    setup_iterator(timeout_q) if timeout_q_count != @prior_timeout_q_count
    @prior_timeout_q_count = timeout_q_count ## Sets current count to compare for next round.

    puts "Type 'exit' to load WebAssociator"
    WebAssociator.start_web_associator
  end


  def setup_iterator(query)
    puts query.count
    ## Assigned to instance variables, so they can display results before each batch runs.
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2

    iterate_query(query) # via ComplexQueryIterator
    # query.each { |id| template_starter(id) }
  end


# Call: UrlVerifier.new.start_url_verifier
  def template_starter(id)
    web_obj = Web.find(id)
    web_url = web_obj.url
    clean_url = @formatter.format_url(web_url)

    if !clean_url.present?
      web_hsh = {urlx: TRUE, sts_code: nil, url_ver_sts: 'invalid', url_ver_date: Time.now}
      web_obj.update_attributes(web_hsh)
    else
      curl_hsh = start_curl(clean_url)
      err_msg = curl_hsh[:err_msg]

      if err_msg.present?
        web_hsh = {urlx: TRUE, sts_code: nil, url_ver_sts: err_msg, url_ver_date: Time.now}
        web_obj.update_attributes(web_hsh)
      else
        update_db(id, web_obj, web_url, clean_url, curl_hsh)
      end
    end
  end

  #Call: UrlVerifier.new.update_db(10)
  def update_db(id, web_obj, web_url, clean_url, curl_hsh)
    sts_code = curl_hsh[:sts_code]
    curl_url = curl_hsh[:curl_url]
    puts "=================================="
    puts "W: #{web_url}"
    puts "F: #{clean_url}"
    puts "C: #{curl_url}"
    puts "S: #{sts_code}\n\n\n"

    if curl_url == web_url ## Important not to refactor this!
      web_obj.update_attributes(urlx: FALSE, url_ver_sts: 'valid', sts_code: sts_code, url_ver_date: Time.now)
      return # Don't remove!  Prevents accidentally running and updating bottom area.
    end

    ## Find or Create FwdWeb Obj based on clean formatted url (not curl yet.)
    if clean_url != web_url
      clean_hsh = {urlx: FALSE, url_ver_sts: 'valid', url: clean_url}
      clean_web_obj = @migrator.save_comp_obj('web', {url: clean_url}, clean_hsh)

      web_hsh = {urlx: TRUE, sts_code: nil, fwd_web_id: clean_web_obj.id, fwd_url: clean_url, url_ver_sts: 'fwd', url_ver_date: Time.now}
      web_obj.update_attributes(web_hsh)

      WebAssociator.transfer_web_associations(web_obj)
      web_obj = clean_web_obj
      web_url = clean_url
    end

    ## Find or Create FwdWeb Obj based on Curl Url
    fwd_hsh = {urlx: FALSE, url_ver_sts: 'valid', url: curl_url}
    fwd_web_obj = @migrator.save_comp_obj('web', {url: curl_url}, fwd_hsh)

    fwd_hsh = {urlx: TRUE, sts_code: nil, fwd_web_id: fwd_web_obj.id, fwd_url: curl_url, url_ver_sts: 'fwd', url_ver_date: Time.now}
    web_obj.update_attributes(fwd_hsh)
    WebAssociator.transfer_web_associations(web_obj)

    starter if (id == @last_id) ## Restart, get next batch of ids.
  end



end
