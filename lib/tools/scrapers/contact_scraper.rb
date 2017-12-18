# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/complex_query_iterator'
# require 'complex_query_iterator'
# require 'final_redirect_url'

class ContactScraper
  # include UrlRedirector #=> concerns/url_redirector.rb
  # include ComplexQueryIterator

  def initialize
    puts "\n== Welcome to the ContactScraper Class! ==\nUpdates Staff Page Data (contacts/employees)"

    welcome_msg = "\n1) This will be pseudocode and instructions for how ContactScraper will work.\n2) More directions and pseudocode ... \n3) More directions and pseudocode ... \n\n"

    puts welcome_msg
  end

  def run_contact_scraper
    # Call: ContactScraper.new.run_contact_scraper
    generate_query
  end


  def generate_query
    puts "Sample query generating for ContactScraper"

    # raw_query = Web
    # .select(:id)
    # .where.not(archived: TRUE)
    # .order("updated_at DESC")

    # iterate_raw_query(raw_query) # via ComplexQueryIterator
  end


end
