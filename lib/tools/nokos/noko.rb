# Call: FindTemp.new.start_find_temp

require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'whois'
require 'delayed_job'

require 'timeout'
require 'net/ping'

module Noko

  # def start_mechanize(web_url)
  def start_noko(web_url)
    noko_hsh = { page: nil, err_msg: nil }

    begin
      begin
        Timeout::timeout(@timeout) do
          puts "\n\n=== WAITING FOR Noko RESPONSE ==="

          agent = Mechanize.new # { |agent| agent.follow_meta_refresh = true }
          agent.user_agent_alias = 'Mac Safari'
          agent.follow_meta_refresh = true
          agent.read_timeout = @timeout
          agent.open_timeout = @timeout # Length of time to wait until a connection is opened in seconds
          agent.idle_timeout = @timeout # Reset connections that have not been used in this many seconds
          agent.keep_alive = false # enable

          begin
            uri = URI(web_url)
            page = agent.get(uri)
            # page = agent.get(web_url)
          rescue Mechanize::ResponseReadError => e
            page = e.force_parse
          end

          page.respond_to?('at_css') ? noko_hsh[:noko_page] = page : noko_hsh[:err_msg] = "Error: Not-Noko-Obj"
            
          #### ORIGINAL ####
          # page = Mechanize.new.get(web_url)
          # page.respond_to?('at_css') ? noko_hsh[:noko_page] = Mechanize.new.get(web_url) : noko_hsh[:err_msg] = "Error: Not-Noko-Obj"
        end
      rescue Timeout::Error # timeout rescue
        noko_hsh[:err_msg] = "timeout:#{@timeout}"
      end
    rescue # LoadError => e  # noko rescue
      err_msg = error_parser("Error: #{$!.message}")
      noko_hsh[:err_msg] = err_msg

      # if err_msg.include?('TCP')
        # puts "\n\nTCP Sleep Delay: (#{@timeout}) seconds\n\n"
        # sleep(@timeout)
        # CheckInt.new.check_int
        # return connection ## See if this works.  Would be lightest option.
        # Process.kill(1, @process_pid)  #=> quits class.
        # Process.kill(17)
        # Process.kill(9, Process.ppid) #=> Too Strong: kills rails server.
      # end
    end

    return noko_hsh
  end


  def error_parser(err_msg)
    if err_msg.include?("404 => Net::HTTPNotFound")
      err_msg = "Error: 404"
    elsif err_msg.include?("connection refused")
      err_msg = "Error: Connection"
    elsif err_msg.include?("undefined method")
      err_msg = "Error: Method"
    elsif err_msg.include?("TCP connection")
      err_msg = "Error: TCP"
    elsif err_msg.include?("execution expired")
      err_msg = "Error: Runtime"
    else
      err_msg = "Error: Undefined"
    end
    return err_msg
  end

end
