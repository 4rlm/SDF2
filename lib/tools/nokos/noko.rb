require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'whois'
require 'delayed_job'

require 'timeout'
require 'net/ping'

module Noko


  # def start_mechanize(url_string)
  def start_noko(url_string)

    begin
      Timeout::timeout(@timeout) do
        @agent = Mechanize.new
        @html = @agent.get(url_string)
        puts "=== GOOD URL ===\nURL: #{url_string}"
      end
    rescue
      # if validate_url(url_string)
      if NetVerifier.new.validate_url(url_string)
        binding.pry
        puts "validating url....."
        start_noko(url_string)
      else
        @html = error_parser($!.message, url_string)
      end
    end
  end


  ## TIP: Consider consolidating: Helper.new.err_code_finder($!.message)
  def error_parser(error_response, url_string)
    if error_response.include?("404 => Net::HTTPNotFound")
      @error_code = "URL Error: 404"
    elsif error_response.include?("connection refused")
      @error_code = "URL Error: Connection"
    elsif error_response.include?("undefined method")
      @error_code = "URL Error: Method"
    elsif error_response.include?("TCP connection")
      @error_code = "URL Error: TCP"
    elsif error_response.include?("execution expired")
      @error_code = "URL Error: Runtime"
    else
      @error_code = "URL Error: Undefined"
    end
    puts "\n\n#{@error_code}: #{url_string}\n\n"
  end

end
