# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'
#
# class UrlVerifier
#   include UrlRedirector #=> concerns/url_redirector.rb
#   include ComplexQueryIterator
#   # Call: IndexerService.new.start_url_redirect
#   # Call: UrlVerifier.new.start_url_verifier
#
#   def initialize
#     puts "\n\n== Welcome to the UrlVerifier Class! ==\n\n"
#     @class_pid = Process.pid
#     @query_limit = 20 #=> Number of rows per batch in raw_query.
#
#     ## Below are Settings for ComplexQueryIterator Module.
#     @dj_wait_time = 3 #=> How often to check dj queue count.
#     @dj_count_limit = 0 #=> Num allowed before releasing next batch.
#     @number_of_groups = 2 #=> Divide query into groups of x.
#   end
#
#   def start_url_verifier
#     generate_query
#   end
#
#   def generate_query
#     raw_query = Indexer
#     .select(:id)
#     .where.not(indexer_status: "Archived")
#     .where(url_redirect_date: nil)
#
#     iterate_raw_query(raw_query) #=> Method is in ComplexQueryIterator.
#   end
#
#   #############################################
#   ## ComplexQueryIterator takes raw_query and creates series of forked iterations based on limits established above in initialize method.  Then it calls 'template_starter(id)' method.  Module serves as bridge for iteration work.
#   #############################################
#
#   def template_starter(id)
#     @indexer = Indexer.where(id: id).select(:id, :raw_url, :clean_url, :indexer_status, :redirect_status).first
#     @raw_url = @indexer.clean_url #=> Verifying clean_url still valid. (vs running raw_url)
#     @indexer_status = @indexer.indexer_status
#     @redirect_status = @indexer.redirect_status
#     start_curl
#     db_updater(id)
#   end
#
#   def get_curl_response
#     @indexer_status = "RD Result"
#     if @raw_url != @curl_url
#       @redirect_status = "Updated"
#     else
#       @redirect_status = "Same"
#     end
#   end
#
#   def db_updater(id)
#     puts "DB raw_url: #{@raw_url}"
#     get_curl_response if @curl_url
#     # puts "NEW curl_url: #{@curl_url}"
#     puts "NEW indexer_status: #{@indexer_status}"
#     puts "NEW redirect_status: #{@redirect_status}"
#     puts "#{"="*30}\n\n"
#
#     @indexer.update_attributes(url_redirect_date: DateTime.now, indexer_status: @indexer_status, redirect_status: @redirect_status, clean_url: @curl_url)
#
#     # @indexer = Indexer.where(id: id).select(:id, :raw_url, :clean_url, :indexer_status, :redirect_status).first
#     # puts @indexer.inspect
#
#     if id == @last_id
#       puts "\n\n===== Last ID: #{id}===== \n\n"
#       starter
#     end
#   end
#
# end
