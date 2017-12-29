# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'
require 'timeout'
require 'internet_connection_validator'
require 'net/ping'

#RUNNER: IndexerService.new.url_redirect_starter
#RUNNER: StafferService.new.cs_starter
module UrlRedirector
  include InternetConnectionValidator
  # extend ActiveSupport::Concern

  def start_curl
    begin

      begin # for timeout
        # Timeout::timeout(2) do
        Timeout.timeout(@timeout) do
          @result = Curl::Easy.perform(@web_url) do |curl|
            puts "=== CURL CONNECTED ==="
            curl.follow_location = true
            curl.useragent = "curb"
            curl.connect_timeout = @timeout
            curl.enable_cookies = true
            curl.head = true #testing - new
            # curl.ssl_verify_peer = false
          end
        end
      rescue Timeout::Error
        updated_hash = { web_status: @timeout_web_status, updated_at: Time.now }
        @web_obj.update_attributes(updated_hash)
        # Process.kill("QUIT", @iterate_raw_query_pid)
      end


      # curl_parser
      @curl_url = @result.last_effective_url
      @curl_url = @curl_url[0..-2] if @curl_url[-1] == '/'

    rescue
      if validate_url(@web_url) #=> via InternetConnectionValidator
        start_curl # restarting curl to try again, if valid.
      else
        @result = nil
        @error_message = "Error: #{$!.message}"
        error_parser
      end
    end

  end

  def error_parser
    puts "ENTERED ERROR PARSER - CHECK @result.status"
    @curl_url = nil

    if @error_message.include?("SSL connect error")
      @web_status = "Error: SSL"
    elsif @error_message.include?("Couldn't resolve host name")
      @web_status = "Error: Host"
    elsif @error_message.include?("Peer certificate")
      @web_status = "Error: Certificate"
    elsif @error_message.include?("Failure when receiving data")
      @web_status = "Error: Transfer"
    else
      @web_status = "Error: Undefined"
    end
  end

  ###### Supporting Methods Below #######
  def url_formatter(url)

    unless url == nil || url == ""
      url.gsub!(/\P{ASCII}/, '')
      url = remove_slashes(url)

      if url.include?("\\")
        url_arr = url.split("\\")
        url = url_arr[0]
      end

      unless url.include?("www.")
        url = url.gsub!("//", "//www.")
      else
        url
      end

      uri = URI(url)
      new_url = "#{uri.scheme}://#{uri.host}"

      if uri.host
        host_parts = uri.host.split(".")
        new_root = host_parts[1]
      end
      return {new_url: new_url, new_root: new_root}
    end
  end

  def remove_slashes(url)
    # For rare cases w/ urls with mistaken double slash twice.
    parts = url.split('//')
    if parts.length > 2
      return parts[0..1].join
    end
    url
  end

end
