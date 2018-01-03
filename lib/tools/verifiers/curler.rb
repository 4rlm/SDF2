# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'
require 'timeout'
# require 'net_verifier'
require 'net/ping'

#RUNNER: IndexerService.new.url_redirect_starter
#RUNNER: StafferService.new.cs_starter
# %w{}.each { |x| require x }

module Curler
  # include NetVerifier
  # extend ActiveSupport::Concern

  def start_curl
    begin

      begin # for timeout
        Timeout.timeout(@timeout) do
        # Timeout.timeout(9000) do
          @formatted_url = WebFormatter.format_url(@web_url)
          if @formatted_url.present?
            @result = Curl::Easy.perform(@formatted_url) do |curl|
              puts "=== CURL CONNECTED ==="
              curl.follow_location = true
              curl.useragent = "curb"
              curl.connect_timeout = @timeout
              curl.enable_cookies = true
              curl.head = true #testing - new
            end
          else
            return nil
          end
        end
      rescue Timeout::Error
        @error_urls << [@web_url]
        @web_obj.update_attributes(web_sts: @timeout_web_sts, updated_at: Time.now)
        # Process.kill("QUIT", @iterate_query_pid)
      end

      # curl_parser
      @curl_url = @result&.last_effective_url
      @curl_url = WebFormatter.format_url(@curl_url) if @curl_url.present?
      @curl_sts_code = @result&.response_code.to_s

    rescue
      # if validate_url(@web_url) #=> via InternetConnectionValidator
      #   start_curl # restarting curl to try again, if valid.
      # else
        @error_urls << [@web_url]
        @result = nil
        @curl_url = nil
        @error_message = "Error: #{$!.message}"
        error_parser
      # end
    end

  end

  def error_parser
    puts "ENTERED ERROR PARSER - CHECK @result.sts"
    @curl_url = nil

    if @error_message.include?("SSL connect error")
      @web_sts = "Error: SSL"
    elsif @error_message.include?("Couldn't resolve host name")
      @web_sts = "Error: Host"
    elsif @error_message.include?("Peer certificate")
      @web_sts = "Error: Certificate"
    elsif @error_message.include?("Failure when receiving data")
      @web_sts = "Error: Transfer"
    else
      @web_sts = "Error: Undefined"
    end
  end


end
