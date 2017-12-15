## AboutTool provides direct access to each tool folder, but is not the only way.  Each tool class, module, or method can be accessed directly or via its parent.  This is highest level parent. AboutTool is also good place for testing to later deploy in other sections or to call collections of complex processes.

class AboutTool
  # Call: AboutTool.new

  def initialize
    puts "Welcome to AboutTools.  Highest level access to all tool folders."
  end


  ###############################################
  # Call: AboutTool.new.start_url_redirect
  # Call: UrlVerifier.new.starter

  def start_url_redirect
    puts ">> start_url_redirect..."
    binding.pry

    UrlVerifier.new
    # UrlVerifier.new.vu_starter
    binding.pry

    # UrlVerifier.new.delay.vu_starter
  end




end
