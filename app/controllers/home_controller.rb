class HomeController < ApplicationController
  # skip_before_action :require_login, only: [:index, :show]
  skip_before_action :authenticate_user!


  def index
    ## Instance Variable below just for example if running data to homepage.
    # @acts = Act.limit(6)
    # @webs = Web.limit(6)
    # @conts = Cont.limit(6)
  end
end
