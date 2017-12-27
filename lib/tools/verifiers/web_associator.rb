
#CALL: UrlVerifier.new.start_web_associator
module WebAssociator
  ## Ensures web url objects with redirect url columns have had their associations tied to new url web obj (for links, texts, accounts, templates).  First need to verify all possible associations web could have.

  def start_web_associator
    binding.pry
    happy
    # Call: LinkTextGrabber.new.start_web_associator
    # generate_query
  end

  def happy
    binding.pry
  end


  # def generate_query
  #   puts "Sample query generating for LinkTextGrabber"
  #
  #   # raw_query = Web
  #   # .select(:id)
  #   # .where.not(archived: TRUE)
  #   # .order("updated_at DESC")
  #
  #   # iterate_raw_query(raw_query) # via ComplexQueryIterator
  # end


end
