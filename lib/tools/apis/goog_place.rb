#######################################
# CALL: Formatter.new.format_act_name('act_name')
# CALL: GoogPlace.new.welcome_gp
# CALL: GoogPlace.new.welcome2
#######################################


%w{run_gp}.each { |x| require x }

class GoogPlace
  include RunGp

  def initialize
    # @client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    @client = GooglePlaces::Client.new('AIzaSyDX5Sn2mNT1vPh_MyMnNOH5YL4cIWaB3s4')
    @formatter = Formatter.new
  end

end
