# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/complex_query_iterator'
# require 'complex_query_iterator'
# require 'final_redirect_url'

class ContScraper
  # include Curler #=> concerns/curler.rb
  # include ComplexQueryIterator

  def initialize
    puts "\n== Welcome to the ContScraper Class! ==\nUpdates Staff Page Data (conts/employees)"

    welcome_msg = "\n1) This will be pseudocode and instructions for how ContScraper will work.\n2) More directions and pseudocode ... \n3) More directions and pseudocode ... \n\n"

    puts welcome_msg
  end

  def run_cont_scraper
    # Call: ContScraper.new.run_cont_scraper
    generate_query
  end


  def generate_query
    puts "Sample query generating for ContScraper"

    # query = Web
    # .select(:id)
    # .where.not(archived: TRUE)
    # .order("updated_at DESC")

    # iterate_query(query) # via ComplexQueryIterator
  end


end
