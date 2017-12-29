# # require 'mechanize'
# # require 'nokogiri'
# # require 'open-uri'
# # require 'delayed_job'
#
# # Call: StafferService.new.start_contact_scraper
# # Call: ContactScraper.new.cs_starter
#
# module ComplexQueryIterator
#   extend ActiveSupport::Concern
#   # include InternetConnectionValidator
#
#   def get_dj_count
#     Delayed::Job.all.count
#   end
#
#   def pause_iteration
#     until get_dj_count <= @dj_count_limit
#       puts "\nWaiting on #{get_dj_count} Queued Jobs | Queue Limit: #{@dj_count_limit}"
#       puts "Please wait #{@dj_wait_time} seconds ...\n\n"
#       sleep(@dj_wait_time)
#     end
#   end
#
#   def iterate_raw_query(raw_query)
#     @iterate_raw_query_pid = Process.pid
#     raw_query.find_in_batches(batch_size: @query_limit) do |batch_of_ids|
#       pause_iteration
#       format_query_results(batch_of_ids)
#     end
#   end
#
#   def format_query_results(batch_of_ids)
#     puts "\n=== FORMATTING NEXT BATCH OF IDs ===\n\n"
#     batch_of_ids = (batch_of_ids.map!{|object| object.id}).in_groups(@stage2_workers) #=> Converts objects into ids, then slices into nested arrays.
#     puts "batch_of_ids: #{batch_of_ids}"
#     puts "PPID: #{Process.ppid}"
#     puts "PID: #{Process.pid}"
#     # batch_of_ids.each { |ids| delay.standard_iterator(ids) }
#     batch_of_ids.each { |ids| standard_iterator(ids) }
#   end
#
#   def standard_iterator(ids)
#     puts "ids: #{ids}"
#
#     ids.each do |id|
#       if id.present?
#         template_starter(id)
#         # delay.template_starter(id)
#       else
#         puts "\n === Empty or End of Query Iteration.=== \n\n"
#         # return
#       end
#
#     end
#
#   end
#
#
# end
