
module IterQuery

  def iterate_query(query)
    # Call: VerUrl.new.start_ver_url
    # Delayed::Worker.max_run_time = 2.seconds
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
      puts "Please wait #{@timeout} seconds ..."
      sleep(@timeout)
    end
  end


  def get_dj_count
    Delayed::Job.all.count
  end


  def format_query_results(batch_of_ids)
    batch_of_ids.in_groups(@workers).each do |group_of_ids|
      standard_iterator(group_of_ids)
      # delay.standard_iterator(group_of_ids)
    end
  end


  def standard_iterator(ids)
    # ids.each { |id| template_starter(id) if id }
    ids.each { |id| delay.template_starter(id) if id }
  end

end
