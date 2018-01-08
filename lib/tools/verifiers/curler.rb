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

  # def start_curl
  def start_curl(web_url)
    curl_hsh = { sts_code: nil, curl_url: nil, err_msg: nil }
    result = nil

    begin
      begin # for timeout
        Timeout.timeout(@timeout) do
        # Timeout.timeout(9000) do
          if web_url.present?
            puts "\n\n=== WAITING FOR CURL RESPONSE ==="
            result = Curl::Easy.perform(web_url) do |curl|
              curl.follow_location = true
              curl.useragent = "curb"
              curl.connect_timeout = @timeout
              curl.enable_cookies = true
              curl.head = true #testing - new
            end # result

            curl_hsh[:sts_code] = result&.response_code.to_s
            curl_hsh[:curl_url] = Formatter.new.format_url(result&.last_effective_url)
          end # conditional
        end # timeout

      rescue Timeout::Error # timeout rescue
        curl_hsh[:err_msg] = "timeout:#{@timeout}"
      end

    rescue # LoadError => e  # curl rescue
      err_msg = error_parser("Error: #{$!.message}")
      # NetVerifier.new.check_internet if err_msg.include?('TCP')
      curl_hsh[:err_msg] = err_msg
    end

    return curl_hsh
  end


  def error_parser(err_msg)
    if err_msg.include?("Couldn't connect to server")
      err_msg = "Error: Expired Url"
    elsif err_msg.include?("SSL connect error")
      err_msg = "Error: SSL"
    elsif err_msg.include?("Couldn't resolve host name")
      err_msg = "Error: Host"
    elsif err_msg.include?("Peer certificate")
      err_msg = "Error: Certificate"
    elsif err_msg.include?("Failure when receiving data")
      err_msg = "Error: Transfer"
    elsif err_msg.include?("TCP connection")
      err_msg = "Error: TCP"
    else
      err_msg = "Error: Undefined"
    end
    return err_msg
  end


end
