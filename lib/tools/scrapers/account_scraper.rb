# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/complex_query_iterator'
# require 'complex_query_iterator'
# require 'final_redirect_url'

class AccountScraper
  # include UrlRedirector #=> concerns/url_redirector.rb
  # include ComplexQueryIterator

  def initialize
    puts "\n== Welcome to the AccountScraper Class! ==\nUpdates Account RT Data (like mailing address and name.)"

    welcome_msg = "\n1) This will be pseudocode and instructions for how AccountScraper will work.\n2) More directions and pseudocode ... \n3) More directions and pseudocode ... \n\n"

    puts welcome_msg
  end

  def run_account_scraper
    # Call: AccountScraper.new.run_account_scraper
    generate_query
  end


  def generate_query
    puts "Sample query generating for AccountScraper"

    # raw_query = Web
    # .select(:id)
    # .where.not(archived: TRUE)
    # .order("updated_at DESC")

    # iterate_raw_query(raw_query) # via ComplexQueryIterator
  end


end
