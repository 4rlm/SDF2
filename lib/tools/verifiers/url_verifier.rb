# Call: UrlVerifier.new.start_url_verifier

# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'final_redirect_url'
require 'complex_query_iterator'
require 'web_associator'
require 'url_redirector'

require 'net/ping'

# %w{complex_query_iterator final_redirect_url}.each { |x| require x }

######### Delayed Job #########
# $ rake jobs:clear

class UrlVerifier
  include UrlRedirector #=> concerns/url_redirector.rb
  include ComplexQueryIterator
  include WebAssociator

  # Call: UrlVerifier.new.start_url_verifier
  def start_url_verifier
    @raw_query_count = nil

    ## Below are Settings for ComplexQueryIterator Module.
    @class_pid = Process.pid
    # @dj_wait_time = 5 #=> How often to check dj queue count.
    @dj_count_limit = 20 #=> Num allowed before releasing next batch.
    @stage2_workers = 3 #=> Divide format_query_results into groups of x.


    ## ROUND 1 ##
    # raw_query = Web.where.not(archived: TRUE).where.not(web_sts: 'timeout').order("updated_at DESC").pluck(:id)
    raw_query = Web.where.not(archived: TRUE).order("updated_at ASC").pluck(:id)
    # raw_query = Web.where(archived: nil).where.not("web_sts LIKE '%timeout%'").order("updated_at DESC").pluck(:id)
    @raw_query_count = raw_query.count
    (@raw_query_count & @raw_query_count > 100) ? @stage1_groups = (@raw_query_count / 100) : @stage1_groups = 2
    @timeout = 5
    @dj_wait_time = @timeout
    @round = 1
    @timeout_web_sts = 'timeout1'
    iterate_raw_query(raw_query) # via ComplexQueryIterator

    ## ROUND 2 ##
    binding.pry
    raw_query = Web.where(archived: TRUE).order("updated_at DESC").pluck(:id)
    # raw_query = Web.where(archived: nil).where(web_sts: 'timeout').order("updated_at DESC").pluck(:id)
    # raw_query = Web.where(archived: nil).where("web_sts LIKE '%timeout%'").order("updated_at DESC").pluck(:id)
    @raw_query_count = raw_query.count
    (@raw_query_count & @raw_query_count > 100) ? @stage1_groups = (@raw_query_count / 50) : @stage1_groups = 2
    @timeout = 15
    @dj_wait_time = @timeout
    @round = 2
    @timeout_web_sts = 'timeout2'
    iterate_raw_query(raw_query) # via ComplexQueryIterator

    ## ROUND 3 ##
    binding.pry
    raw_query = Web.where("web_sts LIKE '%timeout%'").order("updated_at DESC").pluck(:id)
    @raw_query_count = raw_query.count
    (@raw_query_count & @raw_query_count > 100) ? @stage1_groups = (@raw_query_count / 50) : @stage1_groups = 2
    @timeout = 30
    @dj_wait_time = @timeout
    @round = 3
    @timeout_web_sts = 'timeout3'
    iterate_raw_query(raw_query) # via ComplexQueryIterator

    ## ROUND 4 ##
    binding.pry
    raw_query = Web.where("web_sts LIKE '%timeout%'").order("updated_at DESC").pluck(:id)
    @raw_query_count = raw_query.count
    (@raw_query_count & @raw_query_count > 100) ? @stage1_groups = (@raw_query_count / 50) : @stage1_groups = 2
    @timeout = 60
    @dj_wait_time = @timeout
    @round = 4
    @timeout_web_sts = 'timeout4'
    iterate_raw_query(raw_query) # via ComplexQueryIterator

    ## Should be run after UrlVerifier to link web associations to redirect web obj.
    # WebAssociator.start_web_associator
  end

  # #############################################
  # ## ComplexQueryIterator takes raw_query and creates series of forked iterations based on limits established above in initialize method.  Then it calls 'template_starter(id)' method.  Module serves as bridge for iteration work.
  # #############################################

  def template_starter(id)
    @web_obj = Web.find(id)
    @web_url = @web_obj.url
    @web_archived = @web_obj.archived
    @web_sts = @web_obj.web_sts
    @url_redirect_id = @web_obj.url_redirect_id

    start_curl # via UrlRedirector
    update_db(id)
  end

  def update_db(id)
    if !@curl_url && @error_message
      updated_hsh = { web_sts: @web_sts, archived: TRUE, updated_at: Time.now }
      @web_obj.update_attributes(updated_hsh)
    elsif !@curl_url
      puts "MYSTERY RESPONSE - UNEXPECTED"
      binding.pry
    elsif @web_url != @curl_url
      redirect_hsh = {url: @curl_url}
      redirect_full_hsh = {web_sts: 'valid', archived: FALSE, url: @curl_url}

      redirected_url_obj = Web.find_by(redirect_hsh)
      !redirected_url_obj ? redirected_url_obj = Web.create(redirect_full_hsh) : redirected_url_obj.update_attributes(redirect_full_hsh)
      updated_hsh = { web_sts: 'updated', archived: TRUE, url_redirect_id: redirected_url_obj.id, redirect_url: redirected_url_obj.url, updated_at: Time.now }
      @web_obj.update_attributes(updated_hsh)
      ## Links current web_obj associations to new redirect web obj.
      WebAssociator.transfer_web_associations(@web_obj)
    elsif @web_url == @curl_url
      updated_hsh = { web_sts: 'valid', archived: FALSE, updated_at: Time.now }
      @web_obj.update_attributes(updated_hsh)
    end

    starter if (id == @last_id) ## Restart, get next batch of ids.
  end

end
