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
          page = Mechanize.new.get(web_url)
          page.respond_to?('at_css') ? noko_hsh[:noko_page] = Mechanize.new.get(web_url) : noko_hsh[:err_msg] = "Error: Not-Noko-Obj"
        end
      rescue Timeout::Error # timeout rescue
        noko_hsh[:err_msg] = "timeout:#{@timeout}"
      end
    rescue # LoadError => e  # noko rescue
      err_msg = error_parser("Error: #{$!.message}")
      NetVerifier.new.check_internet if err_msg.include?('TCP')
      noko_hsh[:err_msg] = err_msg
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
