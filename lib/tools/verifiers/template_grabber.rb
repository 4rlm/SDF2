# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/complex_query_iterator'
# require 'complex_query_iterator'
# require 'final_redirect_url'


class TemplateGrabber
  # include UrlRedirector #=> concerns/url_redirector.rb
  # include ComplexQueryIterator

  def initialize
    puts "\n== Welcome to the TemplateGrabber Class! ==\nGrabs or Verifies Template (ex. Dealer.com, Cobalt)."

    welcome_msg = "\n1) Should visit each valid non-archived url to verify that current Template is correct.\n2) If template changed, filter home page source code for most common key words used by each template provider.\n3 Track frequency of source key words for future accuracy and speed.  Also, determine versions based on key words, so most precise template scraper version can be used.  Consider creating template scraper version numbers and used based on key words or by name of various html and class names for job titles and sections on staff/location pages.\n\n"

    puts welcome_msg
  end

  def run_template_grabber
    # Call: TemplateGrabber.new.run_template_grabber
    generate_query
  end


  def generate_query
    puts "Sample query generating for TemplateGrabber"

    # raw_query = Web
    # .select(:id)
    # .where.not(archived: TRUE)
    # .order("updated_at DESC")

    # iterate_raw_query(raw_query) # via ComplexQueryIterator
  end


end
