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
    @query_count = nil

    ## Below are Settings for ComplexQueryIterator Module.
    @class_pid = Process.pid
    # @dj_wait_time = 5 #=> How often to check dj queue count.
    @dj_count_limit = 20 #=> Num allowed before releasing next batch.
    @workers = 3 #=> Divide format_query_results into groups of x.
    @timeout = 15
    @dj_wait_time = @timeout
    @timeout_web_sts = 'timeout1'

    @error_urls = [] # For Testing

    # query = Web.where.not(archived: TRUE).where.not(web_sts: 'timeout').order("updated_at DESC").pluck(:id)
    # query = Web.where.not(archived: TRUE).order("updated_at ASC").pluck(:id)
    # query = Web.where.not(archived: TRUE, web_sts: '++').order("updated_at ASC").pluck(:id)
    # query = Web.where("web_sts LIKE '%Error%'").order("updated_at ASC").pluck(:id)
    # query = Web.where("web_sts LIKE '%timeout%'").order("updated_at DESC").pluck(:id)
    # query = Web.where(archived: nil).where.not("web_sts LIKE '%timeout%'").order("updated_at DESC").pluck(:id)
    query = Web.where(web_sts: '++').order("updated_at ASC").pluck(:id)

    obj_in_grp = 150
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

    # iterate_query(query) # via ComplexQueryIterator
    query.each { |id| template_starter(id) }

    ## Should be run after UrlVerifier to link web associations to redirect web obj.
    # WebAssociator.start_web_associator
  end

  # #############################################
  # ## ComplexQueryIterator takes query and creates series of forked iterations based on limits established above in initialize method.  Then it calls 'template_starter(id)' method.  Module serves as bridge for iteration work.
  # #############################################

# Call: UrlVerifier.new.start_url_verifier
  def template_starter(id)
    @web_obj = Web.find(id)
    @web_url = @web_obj.url
    @web_archived = @web_obj.archived
    @web_sts = @web_obj.web_sts
    @url_redirect_id = @web_obj.url_redirect_id

    puts "\n\n=== @web_obj DB data ==="
    puts @web_archived
    puts @web_sts
    puts @url_redirect_id
    puts @web_obj.redirect_url

    @formatted_url = nil
    @curl_url = nil
    @curl_sts_code = nil

    start_curl  # via Curler.start_curl
    puts "\n=== Returned from Curler.start_curl ==="
    puts @web_url
    puts @formatted_url
    puts @curl_url
    puts @curl_sts_code

    update_db(id)
  end


  # Web id: nil, archived: nil, web_sts: nil, sts_code: nil, url: nil, url_redirect_id: nil, redirect_url: nil, redirect_date: nil, temp_sts: nil, temp_date: nil, staff_link_sts: nil, loc_link_sts: nil, staff_text_sts: nil, loc_text_sts: nil, link_text_date: nil, created_at: nil, updated_at: nil>

# Call: UrlVerifier.new.start_url_verifier

  def update_db(id)
    if @formatted_url.class == Array
      @error_urls << @formatted_url
      puts "\n\n===== Long URLs && Error URLs ====="
      @error_urls.uniq.sort!
      @error_urls.each {|array| p array}


      # @error_urls.each {|h| puts "\n#{h}"}
    ## First find or create obj for formatted url if different than web url.  Treat formatted url like a redirect url.
    elsif @formatted_url.present? && @formatted_url != @web_url
      reformat_full_hsh = {web_sts: '++', archived: FALSE, url: @formatted_url}
      reformat_url_obj = Web.find_by(url: @formatted_url)
      !reformat_url_obj ? reformat_url_obj = Web.create(reformat_full_hsh) : reformat_url_obj.update_attributes(reformat_full_hsh)
      @web_obj.update_attributes(archived: TRUE, web_sts: 'updated', sts_code: @curl_sts_code, url_redirect_id: reformat_url_obj.id, redirect_url: reformat_url_obj.url, updated_at: Time.now)
      WebAssociator.transfer_web_associations(@web_obj)
      @web_obj = reformat_url_obj
      @web_url = @formatted_url
    end


    ## Third, update web obj (could be formatted obj) and find or create curl obj to redirect to.
    if !@curl_url.present? && @error_message.present?
      @web_obj.update_attributes(archived: TRUE, web_sts: @web_sts, sts_code: @curl_sts_code, updated_at: Time.now)
    elsif !@curl_url.present?
      @web_obj.update_attributes(archived: TRUE, web_sts: 'bad_ext', updated_at: Time.now)
    elsif @web_url != @curl_url
      redirect_full_hsh = {web_sts: '++', archived: FALSE, url: @curl_url}
      redirected_url_obj = Web.find_by(url: @curl_url)
      !redirected_url_obj ? redirected_url_obj = Web.create(redirect_full_hsh) : redirected_url_obj.update_attributes(redirect_full_hsh)
      @web_obj.update_attributes(archived: TRUE, web_sts: '--', sts_code: @curl_sts_code, url_redirect_id: redirected_url_obj.id, redirect_url: redirected_url_obj.url, updated_at: Time.now)
      WebAssociator.transfer_web_associations(@web_obj)
    elsif @web_url == @curl_url
      @web_obj.update_attributes(archived: FALSE, web_sts: '++', sts_code: @curl_sts_code, updated_at: Time.now)
    end

    starter if (id == @last_id) ## Restart, get next batch of ids.
  end


  ### BELOW IS ORIGINAL OF ABOVE METHOD.  ###
  # def update_db(id)
  #   if !@curl_url && @error_message
  #     updated_hsh = { web_sts: @web_sts, archived: TRUE, updated_at: Time.now }
  #     @web_obj.update_attributes(updated_hsh)
  #   elsif !@curl_url
  #     puts "MYSTERY RESPONSE - UNEXPECTED"
  #     binding.pry
  #   elsif @web_url != @curl_url
  #     redirect_hsh = {url: @curl_url}
  #     redirect_full_hsh = {web_sts: '++', archived: FALSE, url: @curl_url}
  #
  #     redirected_url_obj = Web.find_by(redirect_hsh)
  #     !redirected_url_obj ? redirected_url_obj = Web.create(redirect_full_hsh) : redirected_url_obj.update_attributes(redirect_full_hsh)
  #     updated_hsh = { web_sts: 'updated', archived: TRUE, url_redirect_id: redirected_url_obj.id, redirect_url: redirected_url_obj.url, updated_at: Time.now }
  #     @web_obj.update_attributes(updated_hsh)
  #     ## Links current web_obj associations to new redirect web obj.
  #     WebAssociator.transfer_web_associations(@web_obj)
  #   elsif @web_url == @curl_url
  #     updated_hsh = { web_sts: '++', archived: FALSE, updated_at: Time.now }
  #     @web_obj.update_attributes(updated_hsh)
  #   end
  #
  #   starter if (id == @last_id) ## Restart, get next batch of ids.
  # end



end
