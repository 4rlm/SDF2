# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/complex_query_iterator'
# require 'complex_query_iterator'
# require 'final_redirect_url'

class ActScraper
  # include Curler #=> concerns/curler.rb
  # include ComplexQueryIterator

  def initialize
    puts "\n== Welcome to the ActScraper Class! ==\nUpdates Act RT Data (like mailing adr and name.)"

    welcome_msg = "\n1) This will be pseudocode and instructions for how ActScraper will work.\n2) More directions and pseudocode ... \n3) More directions and pseudocode ... \n\n"

    puts welcome_msg
  end

  def run_act_scraper
    # Call: ActScraper.new.run_act_scraper
    generate_query
  end


  def generate_query
    puts "Sample query generating for ActScraper"

    # query = Web
    # .select(:id)
    # .where.not(archived: TRUE)
    # .order("updated_at DESC")

    # iterate_query(query) # via ComplexQueryIterator
  end


end
