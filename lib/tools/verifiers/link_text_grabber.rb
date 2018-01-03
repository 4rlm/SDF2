# require 'mechanize'
# require 'nokogiri'
# require 'open-uri'
# require 'delayed_job'
# require 'curb'

# require 'iterators/complex_query_iterator'
# require 'complex_query_iterator'
# require 'final_redirect_url'


class LinkTextGrabber
  # include Curler #=> concerns/curler.rb
  # include ComplexQueryIterator

  def initialize
    puts "\n\n== Welcome to the LinkTextGrabber Class! ==\nGrabs or Verifies Location & Staff page Links and Text."

    welcome_msg = "\n#1) Should visit each valid non-archived url to verify that current Link (location, staff) correct.\n#2) Verify valid link via url redirect with full link (looking for redirect and/or sts code/error msg.)\n#3) If invalid link, try most common links per template to use first.  If not valid, try most common texts (href link text) per template.\n\n"

    puts welcome_msg
  end

  def run_link_text_grabber
    # Call: LinkTextGrabber.new.run_link_text_grabber
    generate_query
  end


  def generate_query
    puts "Sample query generating for LinkTextGrabber"

    # query = Web
    # .select(:id)
    # .where.not(archived: TRUE)
    # .order("updated_at DESC")

    # iterate_query(query) # via ComplexQueryIterator
  end


end
