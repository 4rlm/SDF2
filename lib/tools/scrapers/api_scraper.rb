# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/complex_query_iterator'
# require 'complex_query_iterator'
# require 'final_redirect_url'

class ApiScraper
  # include UrlRedirector #=> concerns/url_redirector.rb
  # include ComplexQueryIterator

  def initialize
    puts "\n== Welcome to the ApiScraper Class! ==\nGrabs or Verifies Google Places Data."

    welcome_msg = "\n1) This will be pseudocode and instructions for how ApiScraper will work.\n2) More directions and pseudocode ... \n3) More directions and pseudocode ... \n\n"

    puts welcome_msg
  end

  def run_api_scraper
    # Call: ApiScraper.new.run_api_scraper
    generate_query
  end


  def generate_query
    puts "Sample query generating for ApiScraper"

    # raw_query = Web
    # .select(:id)
    # .where.not(archived: TRUE)
    # .order("updated_at DESC")

    # iterate_raw_query(raw_query) # via ComplexQueryIterator
  end


end
