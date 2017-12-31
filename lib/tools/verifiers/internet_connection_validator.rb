require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'whois'
require 'delayed_job'

require 'timeout'
require 'net/ping'

#RUNNER: IndexerService.new.url_redirect_starter
#RUNNER: StafferService.new.cs_starter
module InternetConnectionValidator
  # extend ActiveSupport::Concern

  ############ FOR MECHANIZE ONLY ############
  # MOVED TO NOKO

  def start_mechanize(url_string)
    puts "Starting mechanize ...."
    begin
      Timeout::timeout(@timeout) do
        @agent = Mechanize.new
        @html = @agent.get(url_string)
        puts "=== GOOD URL ===\nURL: #{url_string}"
      end
    rescue
      if validate_url(url_string)
        puts "validating url....."
        start_mechanize(url_string)
      else
        @html = error_parser($!.message, url_string)
      end
    end
  end

  ############ FOR WhoisScraper ONLY ############
  def access_whois_directory(url_string, uri_host)
    puts "Accessing WhoIs Directory ...."
    begin
      Timeout::timeout(@timeout) do
        @record = Whois.whois(uri_host) #=> Using Whois Gem.
        puts "=== GOOD URL ===\nURL: #{url_string}"
      end
    rescue
      if validate_url(url_string)
        puts "validating url....."
        access_whois_directory(url_string)
      else
        @whois_error = error_parser($!.message, url_string)
      end
    end
  end

  ######################################################
  ################## MAIN - UNIVERSAL ##################
  ######################################################

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

  def ping_url
    pingable_urls = %w(
    http://speedtest.hafslundtelekom.net/
    http://www.whatsmyip.org/
    https://fast.com/
    https://www.cox.com/
    http://speedtest.xfinity.com/
    https://www.iplocation.net/
    http://www.bandwidthplace.com/
    http://www.speedinternet.co/
    http://www.centurylink.com/
    https://frontier.com/
    https://www.windstream.com/
    https://www.rcn.com/
    http://atlanticbb.com/
    http://mygrande.com/
    https://speedof.me/
    https://www.lifewire.com/
    https://www.cnet.com/
    https://www.megapath.com/
    https://www.consolidated.com/
    http://www.merck.com/
    https://www.pfizer.com/
    https://www.gsk.com/
    https://www.jnj.com/
    https://www.johnsonsbaby.com/
    https://www.discovernursing.com/
    https://www.cancer.org/
    https://www.verizon.com/)
    pingable_urls.sample
  end

  def test_internet_connection
    sample_url = ping_url
    begin
      result = true if open(ping_url)
    rescue
      result = false
    end
    puts "Internet Connection: #{result} via #{sample_url} ==="
    result
  end

  def url_exist?(url_string)
    puts "Checking if URL Exists..."
    begin
      Timeout::timeout(10) do
        url = URI.parse(url_string)
        req = Net::HTTP.new(url.host, url.port)
        req.use_ssl = (url.scheme == 'https')
        res = req.request_head(url || '/')
        if res.kind_of?(Net::HTTPRedirection)
          url_exist?(res['location']) # Go after any redirect and make sure you can access the redirected URL
        else
          return
          # res.code[0] != "4" #false if http code starts with 4 - error on your side.
        end
      end

    rescue
      # puts "\n$!.message: #{$!.message}\n\n"
      false #false if can't find the server
    end
  end

  #CALL: InternetConnectionValidator.validate_url(url_string)
  def validate_url(url_string)
    # good = 'http://www.google.com/index.html'
    # bad  = 'http://www.ruby-lang.org/index.html'

    # binding.pry
    # p1 = Net::Ping::HTTP.new(good)
    # p2 = Net::Ping::HTTP.new(bad)
    # binding.pry
    #
    # p p2.ping?
    # p p2.warning
    # p p2.exception
    # binding.pry


    if url_exist?(url_string)
      puts "=== GOOD URL ===\nURL: #{url_string}"
    else
      if not test_internet_connection
        connection = false
        ping_attempt_limit = 5
        ping_attempt_count = 1
        sleep_time = 3

        while !connection
          sleep_time * ping_attempt_count
          puts "\nNO INTERNET CONNECTION\nCONNECTION TEST ATTEMPTS: #{ping_attempt_count}\nTRY AGAIN IN: #{sleep_time} SECONDS\n#{"="*30}\n\n"
          sleep(sleep_time)
          connection = test_internet_connection
          ping_attempt_count += 1
          break if connection
          if ping_attempt_count >= ping_attempt_limit
            puts "\n=== Forced Exit due to #{ping_attempt_limit} Failed Connection Attempts! ===\n\n"
            puts "\n\n@class_pid: #{@class_pid}\n\n"
            puts "\n\n@iterate_query_pid: #{@iterate_query_pid}\n\n"

            ### Best Approach ###
            # Process.kill("QUIT", @class_pid)  #=> quits class.
            Process.kill("QUIT", @iterate_query_pid) #=> quits top level iterator.

            ### Works Well ###
            # Process.kill(9, @class_pid) #=> kills class.
            # Process.kill(9, @iterate_query_pid) #=> kills top level iterator.

            ### Too Strong ###
            # Process.kill(9, Process.pid) #=> kills rails server.
            # Process.kill(9, Process.ppid) #=> kills rails server.
          end

        end
        validate_url(url_string)
      end
    end

  end

end





################################
=begin
### BORROWED FROM OLD PAGE FINDER - TRY TO INTEGRATE ###
error_msg = "Error: #{$!.message}"
sts = nil
indexer_sts = nil
found = false

indexer_terms = IndexerTerm.where(category: "url_redirect").where(sub_category: error_msg)
indexer_terms.each do |term|
  if error_msg.include?(term.criteria_term)

    sts = term.response_term
    found = true
  else
    sts = error_msg
  end

  indexer_sts = sts == "TCP Error" ? sts : "PF Error"
  break if found
end # indexer_terms iteration ends
=end
################################
