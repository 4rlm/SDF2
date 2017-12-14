# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'
#
# #RUNNER: IndexerService.new.url_redirect_starter
# #RUNNER: StafferService.new.cs_starter
# module UrlRedirector
#   extend ActiveSupport::Concern
#   include InternetConnectionValidator
#
#   def start_curl
#     puts "Starting curl ...."
#
#     begin
#       @result = Curl::Easy.perform(@raw_url) do |curl|
#         puts "=== CURL CONNECTED ==="
#         curl.follow_location = true
#         curl.useragent = "curb"
#         curl.connect_timeout = 10
#         curl.enable_cookies = true
#         # curl.ssl_verify_peer = false
#       end
#       curl_parser
#     rescue
#       if validate_url(@raw_url) #=> via InternetConnectionValidator
#         puts "validating url....."
#         start_curl
#       else
#         @result = nil
#         @error_message = "Error: #{$!.message}"
#         error_parser
#       end
#     end
#
#   end
#
#   def curl_parser
#     curl_hash = url_formatter(@result.last_effective_url)
#     @curl_url = curl_hash[:new_url]
#     puts "@curl_url: #{@curl_url}"
#   end
#
#   def error_parser
#     @indexer_status = "RD Error", @curl_url = nil
#     if @error_message.include?("SSL connect error")
#       @redirect_status = "Error: SSL"
#     elsif @error_message.include?("Couldn't resolve host name")
#       @redirect_status = "Error: Host"
#     elsif @error_message.include?("Peer certificate")
#       @redirect_status = "Error: Certificate"
#     elsif @error_message.include?("Failure when receiving data")
#       @redirect_status = "Error: Transfer"
#     else
#       @redirect_status = "Error: Undefined"
#     end
#   end
#
#   ###### Supporting Methods Below #######
#   def url_formatter(url)
#     unless url == nil || url == ""
#       url.gsub!(/\P{ASCII}/, '')
#       url = remove_slashes(url)
#       if url.include?("\\")
#         url_arr = url.split("\\")
#         url = url_arr[0]
#       end
#       unless url.include?("www.")
#         url = url.gsub!("//", "//www.")
#       else
#         url
#       end
#
#       uri = URI(url)
#       new_url = "#{uri.scheme}://#{uri.host}"
#
#       if uri.host
#         host_parts = uri.host.split(".")
#         new_root = host_parts[1]
#       end
#       return {new_url: new_url, new_root: new_root}
#     end
#   end
#
#   def remove_slashes(url)
#     # For rare cases w/ urls with mistaken double slash twice.
#     parts = url.split('//')
#     if parts.length > 2
#       return parts[0..1].join
#     end
#     url
#   end
#
# end
