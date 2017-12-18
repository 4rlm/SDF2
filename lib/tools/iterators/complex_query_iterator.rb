require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'delayed_job'

######### Delayed Job #########
# $ rake jobs:clear

# Call: StafferService.new.start_contact_scraper
# Call: ContactScraper.new.cs_starter

module ComplexQueryIterator
  # extend ActiveSupport::Concern
  # include InternetConnectionValidator


  def iterate_raw_query(raw_query)
    # Call: UrlVerifier.new.run_url_verifier

    @iterate_raw_query_pid = Process.pid
    raw_query.find_in_batches(batch_size: @query_limit) do |batch_of_ids|
      pause_iteration
      format_query_results(batch_of_ids)
    end
  end


  def pause_iteration
    until get_dj_count <= @dj_count_limit
      puts "\nWaiting on #{get_dj_count} Queued Jobs | Queue Limit: #{@dj_count_limit}"
      puts "Please wait #{@dj_wait_time} seconds ...\n\n"
      sleep(@dj_wait_time)
    end
  end


  def get_dj_count
    Delayed::Job.all.count
  end


  def format_query_results(batch_of_ids)
    batch_of_ids = (batch_of_ids.map!{|object| object.id}).in_groups(@number_of_groups) #=> Converts objects into ids, then slices into nested arrays.

    puts "batch_of_ids: #{batch_of_ids}"
    puts "PPID: #{Process.ppid}"
    puts "PID: #{Process.pid}"

    # batch_of_ids.each { |ids| delay.standard_iterator(ids) }
    batch_of_ids.each { |ids| standard_iterator(ids) }
  end


  def standard_iterator(ids)
    puts "ids: #{ids}"
    ids.each { |id| template_starter(id) if id }
    # ids.each { |id| delay.template_starter(id) if id }
  end

end
