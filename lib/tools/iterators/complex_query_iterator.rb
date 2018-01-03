# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# %w{mechanize nokogiri open-uri delayed_job}.each {|x| require x }


######### Delayed Job #########
# $ rake jobs:clear

# Call: StafferService.new.start_cont_scraper
# Call: ContScraper.new.cs_starter

module ComplexQueryIterator
  # extend ActiveSupport::Concern
  # include InternetConnectionValidator

  def iterate_query(query)
    # Call: UrlVerifier.new.start_url_verifier
    @iterate_query_pid = Process.pid

    query.in_groups(@group_count).each do |batch_of_ids|
      @query_count -= batch_of_ids&.count
      pause_iteration
      format_query_results(batch_of_ids)
    end

  end


  def pause_iteration
    until get_dj_count <= @dj_count_limit
      puts "\nWaiting on #{get_dj_count} Queued Jobs | Queue Limit: #{@dj_count_limit}"
      puts "Total Query Count: #{@query_count}, Timeout: #{@timeout}"
      puts "Please wait #{@dj_wait_time} seconds ..."
      sleep(@dj_wait_time)
    end
  end


  def get_dj_count
    Delayed::Job.all.count
  end


  def format_query_results(batch_of_ids)
    batch_of_ids.in_groups(@workers).each do |group_of_ids|
      puts "\n\n==> batch_of_ids: #{batch_of_ids} <=="
      puts "\nPPID: #{Process.ppid}"
      puts "PID: #{Process.pid}"

      standard_iterator(group_of_ids)
      # delay.standard_iterator(group_of_ids)
    end
  end


  def standard_iterator(ids)
    puts "ids: #{ids}"
    # ids.each { |id| template_starter(id) if id }
    ids.each { |id| delay.template_starter(id) if id }
  end

end
