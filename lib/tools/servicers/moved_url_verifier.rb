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
#     @stage2_workers = 2 #=> Divide query into groups of x.
#   end
#
#   def start_url_verifier
#     generate_query
#   end
#
#   def generate_query
#     raw_query = Indexer
#     .select(:id)
#     .where.not(indexer_sts: "Archived")
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
#     @indexer = Indexer.where(id: id).select(:id, :raw_url, :clean_url, :indexer_sts, :redirect_sts).first
#     @raw_url = @indexer.clean_url #=> Verifying clean_url still valid. (vs running raw_url)
#     @indexer_sts = @indexer.indexer_sts
#     @redirect_sts = @indexer.redirect_sts
#     start_curl
#     db_updater(id)
#   end
#
#   def get_curl_response
#     @indexer_sts = "RD Result"
#     if @raw_url != @curl_url
#       @redirect_sts = "Updated"
#     else
#       @redirect_sts = "Same"
#     end
#   end
#
#   def db_updater(id)
#     puts "DB raw_url: #{@raw_url}"
#     get_curl_response if @curl_url
#     # puts "NEW curl_url: #{@curl_url}"
#     puts "NEW indexer_sts: #{@indexer_sts}"
#     puts "NEW redirect_sts: #{@redirect_sts}"
#     puts "#{"="*30}\n\n"
#
#     @indexer.update_attributes(url_redirect_date: DateTime.now, indexer_sts: @indexer_sts, redirect_sts: @redirect_sts, clean_url: @curl_url)
#
#     # @indexer = Indexer.where(id: id).select(:id, :raw_url, :clean_url, :indexer_sts, :redirect_sts).first
#     # puts @indexer.inspect
#
#     if id == @last_id
#       puts "\n\n===== Last ID: #{id}===== \n\n"
#       starter
#     end
#   end
#
# end
