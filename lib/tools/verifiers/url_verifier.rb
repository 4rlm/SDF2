# Call: UrlVerifier.new.start_url_verifier

require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'delayed_job'
require 'curb'
require 'timeout'
require 'net/ping'
# require 'final_redirect_url'
require 'complex_query_iterator'
require 'web_associator'
require 'curler'
require 'net/ping'
# require 'https'
require 'openssl'
require "net/http"
# %w{complex_query_iterator final_redirect_url}.each { |x| require x }

######### Delayed Job #########
# $ rake jobs:clear

class UrlVerifier
  include Curler #=> concerns/curler.rb
  include ComplexQueryIterator
  include WebAssociator

  # Call: UrlVerifier.new.start_url_verifier
  def start_url_verifier
    ## Settings for ComplexQueryIterator Module.
    @timeout = 30
    @dj_count_limit = 30 #=> Num allowed before releasing next batch.
    @workers = 4 #=> Divide format_query_results into groups of x.

    # query = Web.where.not(url_archived: TRUE).where.not(web_sts: 'timeout').order("updated_at DESC").pluck(:id)
    # query = Web.where.not(url_archived: TRUE).order("updated_at ASC").pluck(:id)
    # query = Web.where(url_archived: TRUE).order("updated_at ASC").pluck(:id)
    # query = Web.where.not(url_archived: TRUE, web_sts: '++').order("updated_at ASC").pluck(:id)
    # query = Web.where("web_sts LIKE '%Error%'").order("updated_at ASC").pluck(:id)
    # query = Web.where("web_sts LIKE '%timeout%'").order("updated_at DESC").pluck(:id)
    # query = Web.where(url_archived: nil).where.not("web_sts LIKE '%timeout%'").order("updated_at DESC").pluck(:id)
    # query = Web.where.not(web_sts: '++').order("updated_at ASC").pluck(:id)
    # query = Web.all.order("updated_at ASC").pluck(:id)
    # query = Web.where.not(web_sts: 'valid').order("updated_at ASC").pluck(:id)
    # query = Web.where(url_archived: TRUE).order("updated_at ASC").pluck(:id)
    # query = Web.where(web_sts: nil).order("updated_at ASC").pluck(:id)
    # query = Web.where.not(url_archived: TRUE).order("updated_at ASC").pluck(:id)

    ## Primary Query ##
    # query = Web.where(web_sts: nil).order("updated_at ASC").pluck(:id)

    ## Clean Up Query for Bad Internet Connections ##
    query = Web.where(web_sts: 'Error: Host').order("updated_at ASC").pluck(:id)

    obj_in_grp = 50
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

    iterate_query(query) # via ComplexQueryIterator
    # query.each { |id| template_starter(id) }

    puts "Should run below method as an insurance, to make sure associations got moved to redirected obj."
    ## Should be run after UrlVerifier to link web associations to redirect web obj.
    binding.pry
    WebAssociator.start_web_associator
  end


# Call: UrlVerifier.new.start_url_verifier
  def template_starter(id)
    web_obj = Web.find(id)
    web_url = web_obj.url
    formatted_url = Formatter.new.format_url(web_url)

    if !formatted_url.present?
      web_obj.update_attributes(url_archived: TRUE, web_sts: 'invalid', sts_code: nil, redirect_date: Time.now)
    else
      curl_hsh = start_curl(formatted_url) # via Curler.start_curl
      err_msg = curl_hsh[:err_msg]
      err_msg.present? ? web_obj.update_attributes(url_archived: TRUE, web_sts: err_msg, sts_code: nil, redirect_date: Time.now) : update_db(id, web_obj, web_url, formatted_url, curl_hsh)
    end
  end

  #Call: UrlVerifier.new.update_db(10)
  def update_db(id, web_obj, web_url, formatted_url, curl_hsh)
    sts_code = curl_hsh[:sts_code]
    curl_url = curl_hsh[:curl_url]
    puts "=================================="
    puts "W: #{web_url}"
    puts "F: #{formatted_url}"
    puts "C: #{curl_url}"
    puts "S: #{sts_code}\n\n\n"

    if curl_url == web_url ## Important not to refactor this!
      web_obj.update_attributes(url_archived: FALSE, web_sts: 'valid', sts_code: sts_code, redirect_date: Time.now)
      return # Don't remove!  Prevents accidentally running and updating bottom area.
    end

    if formatted_url != web_url
      reformat_full_hsh = {url_archived: FALSE, web_sts: 'valid', url: formatted_url}
      reformat_url_obj = Web.find_by(url: formatted_url)
      !reformat_url_obj ? reformat_url_obj = Web.create(reformat_full_hsh) : reformat_url_obj.update_attributes(reformat_full_hsh)
      web_obj.update_attributes(url_archived: TRUE, web_sts: 'redirect', sts_code: nil, url_redirect_id: reformat_url_obj.id, redirect_url: reformat_url_obj.url, redirect_date: Time.now)
      WebAssociator.transfer_web_associations(web_obj)
      web_obj = reformat_url_obj
      web_url = formatted_url
    end

    redirect_full_hsh = {url_archived: FALSE, web_sts: 'valid', url: curl_url}
    redirected_url_obj = Web.find_by(url: curl_url)

    if !redirected_url_obj
      redirected_url_obj = Web.create(redirect_full_hsh)
    else
      redirected_url_obj.update_attributes(redirect_full_hsh)
    end

    web_obj.update_attributes(url_archived: TRUE, web_sts: 'redirect', sts_code: nil, url_redirect_id: redirected_url_obj.id, redirect_url: redirected_url_obj.url, redirect_date: Time.now)
    WebAssociator.transfer_web_associations(web_obj)

    starter if (id == @last_id) ## Restart, get next batch of ids.
  end



end
