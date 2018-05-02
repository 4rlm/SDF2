#CALL: GpStart.new.start_gp_act
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'gp_run'

class GpStart
  include IterQuery
  include GpRun

  def initialize
    @dj_on = false
    @dj_count_limit = 0
    @dj_workers = 3
    @obj_in_grp = 9
    @dj_refresh_interval = 5
    @db_timeout_limit = 200
    @count = 0
    @cut_off = 10.days.ago
    @formatter = Formatter.new
    @mig = Mig.new
    @multi_spots = true
    @client = GooglePlaces::Client.new(ENV['GOOGLE_PLACES_API'])
    @spot_start_time = nil
    @gp_acts = []
    @current_process = "GpStart"
  end


  #CALL: GpStart.new.start_gp_act
  def get_query
    query = []

    ## Multiple Spot Query - COP!
    if !query.any?
      @multi_spots = true
      query = Act.includes(:webs)
        .where("acts.gp_date < ? OR gp_date IS NULL", @cut_off).references(:acts)
        .where(webs: {cop: true})
        .where.not(acts: {lat: nil, lon: nil})
        .where(acts: {gp_id: nil, gp_sts: ['Valid', nil]})
        .select(:id).order("gp_date ASC")[0..0].pluck(:id)
    end

    ## ## Skipped Sts Query ##
    if !query.any?
      @multi_spots = false
      query = Act.select(:id)
        .where(gp_sts: 'Skipped')
        .where('gp_date < ? OR gp_date IS NULL', @cut_off)
        .order("id ASC").pluck(:id)
    end

    query
  end


  def start_gp_act
    query = get_query
    while query.any?
      setup_iterator(query)
      query = get_query
      break if !query.any?
    end
  end

  def setup_iterator(query)
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
    @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }
  end

  #CALL: GpStart.new.start_gp_act
  def template_starter(id)
    # samp = Random.rand(11)
    # puts "Sleeping....#{samp}"
    # sleep(samp)

    @spot_start_time = Time.now
    @gp_acts = []
    @act = Act.find(id)
    act_name_addr = pre_remove_invalids
    gp_hsh_arr = get_spot(act_name_addr)

    if gp_hsh_arr&.any?
      gp_hsh_arr.each do |gp_hsh|
        act = Act.find_or_create_by(gp_id: gp_hsh[:gp_id])
        web = find_web(gp_hsh[:url])
        update_db(act, web, gp_hsh)
      end
    else
      @act.update(gp_sts: 'Invalid', gp_date: Time.now)
    end

    act_gp_date = @act.gp_date
    if !act_gp_date || (act_gp_date < @spot_start_time) || !@gp_acts&.uniq&.include?(@act.reload)
      @act.update(gp_sts: 'Skipped', gp_date: Time.now)
    end
  end


  def update_db(act, web, gp_hsh)

    if act.present?
      act.webs << web if (web.present? && !act.webs&.include?(web))
      act_hsh = gp_hsh.except!(:url)
      @gp_acts << act.update(act_hsh)

      # act.web = web if (web.present? && (act.web != web))
      # url = act.web&.url
      # act_hsh = gp_hsh.slice!(:url)
      # @gp_acts << act.update(act_hsh)
    end
  end


  def find_web(gp_url)
    if gp_url.present?
      http_s_hsh = @formatter.make_http_s(gp_url)
      if http_s_hsh.present?
        web = Web.find_by(url: http_s_hsh[:https])
        web = Web.find_by(url: http_s_hsh[:http]) if !web.present?
        web = Web.create(url: gp_url) if !web.present?
        return web
      end
    end
  end


  def pre_remove_invalids
    if @act.present?
      act_name = @act.act_name
      city = @act.city
      state = @act.state
      ## Remove Undesirable Words from Act Name before sending to Goog ##
      invalid_list = %w(service services contract parts collision repairs repair credit loan department dept and safety safe equipment equip body shop wash detailing detail finance financial mobile rv motorsports mobility)

      inval_hsh = @formatter.remove_invalids(act_name, invalid_list)
      act_name = inval_hsh[:act_name]

      ### GET GOOG RESULTS ###
      if city && state
        act_name_addr = "#{act_name} in #{city}, #{state}"
      elsif city
        act_name_addr = "#{act_name} in #{city}"
      elsif state
        act_name_addr = "#{act_name} in #{state}"
      else
        act_name_addr = act_name
      end
      return act_name_addr
    end
  end



end
