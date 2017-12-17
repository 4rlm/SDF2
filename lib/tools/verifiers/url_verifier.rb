# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/complex_query_iterator'
require 'complex_query_iterator'
require 'final_redirect_url'
# FinalRedirectUrl


class UrlVerifier
  include UrlRedirector #=> concerns/url_redirector.rb
  include ComplexQueryIterator
  # include FinalRedirectUrl #=> JUST SAMPLING THIS!!

  # Call: IndexerService.new.start_url_redirect
  # Call: UrlVerifier.new.vu_starter

  def initialize
    puts "\n\n== Welcome to the UrlVerifier Class! ==\n\n"

    # @class_pid = Process.pid
    @query_limit = 20 #=> Number of rows per batch in raw_query.

    ## Below are Settings for ComplexQueryIterator Module.
    @dj_wait_time = 3 #=> How often to check dj queue count.
    @dj_count_limit = 0 #=> Num allowed before releasing next batch.
    @number_of_groups = 2 #=> Divide query into groups of x.
  end

  def vu_starter
    # Call: UrlVerifier.new.vu_starter
    generate_query
  end


  def generate_query
    raw_query = Web
    .select(:id)
    .where.not(archived: TRUE)
    # .order("updated_at DESC")
    # .order(:updated_at).reverse

    iterate_raw_query(raw_query) # via ComplexQueryIterator
  end

  # #############################################
  # ## ComplexQueryIterator takes raw_query and creates series of forked iterations based on limits established above in initialize method.  Then it calls 'template_starter(id)' method.  Module serves as bridge for iteration work.
  # #############################################

  def template_starter(id)
    # @web_obj = Web.find(id)
    @web_obj = Web.where(id: id).select(:id, :archived, :web_status, :url, :url_redirect_id).first

    @web_url = @web_obj.url
    @web_archived = @web_obj.archived
    @web_status = @web_obj.web_status
    @url_redirect_id = @web_obj.url_redirect_id

    start_curl # via UrlRedirector
    update_db(id)
  end

  def update_db(id)

    if !@curl_url && @error_message
      updated_hash = { web_status: @web_status, archived: TRUE }
      @web_obj.update_attributes(updated_hash)
    elsif !@curl_url
      puts "MYSTERY RESPONSE - UNEXPECTED"
      binding.pry
    elsif @web_url != @curl_url
      redirect_hash = {url: @curl_url}
      redirect_full_hash = {web_status: 'valid', archived: FALSE, url: @curl_url}

    # Call: UrlVerifier.new.vu_starter
      redirected_url_obj = Web.find_by(redirect_hash)
      !redirected_url_obj ? redirected_url_obj = Web.create(redirect_full_hash) : redirected_url_obj.update_attributes(redirect_full_hash)
      updated_hash = {web_status: 'updated', archived: TRUE, url_redirect_id: redirected_url_obj.id}
      @web_obj.update_attributes(updated_hash)
    end

    starter if (id == @last_id) ## Restart, get next batch of ids.
  end

end
