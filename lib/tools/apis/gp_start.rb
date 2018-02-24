#CALL: GpStart.new.start_gp_act
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'

class GpStart
  include IterQuery

  def initialize
    @dj_on = false
    @dj_count_limit = 0
    @dj_workers = 4
    @obj_in_grp = 40
    @dj_refresh_interval = 10
    @db_timeout_limit = 60
    @count = 0
    @cut_off = 5.days.ago
    @gp = GpApi.new
    @formatter = Formatter.new
    @mig = Mig.new
  end

  def get_query
    ## ## Valid Sts Query ##
    val_sts_arr = ['Valid', nil]
    query = Act.select(:id)
      .where(gp_sts: val_sts_arr)
      .where('gp_date < ? OR gp_date IS NULL', @cut_off)
      .order("id ASC").pluck(:id)

    puts query.count
    sleep(1)
    # binding.pry
    return query
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

  def template_starter(id)
    act = Act.find(id)
    act_name = act.act_name
    orig_act_name = act_name
    city = act.city
    state = act.state
    url = act.web&.url
    gp_id = act.gp_id

    ## Remove Undesirable Words from Act Name before sending to Goog ##
    invalid_list = %w(service services contract parts collision repairs repair credit loan department dept and safety safe equipment equip body shop wash detailing detail finance financial mobile rv motorsports mobility)

    inval_hsh = @formatter.remove_invalids(act_name, invalid_list)
    act_name = inval_hsh[:act_name]

    ### GET GOOG RESULTS ###
    if city && state
      act_name = "#{act_name} in #{city}, #{state}"
    elsif city
      act_name = "#{act_name} in #{city}"
    elsif state
      act_name = "#{act_name} in #{state}"
    end

    gp_hsh = @gp.get_spot(act_name, url, gp_id)
    update_db(act, gp_hsh)
  end


  #CALL: GpStart.new.start_gp_act
  def update_db(act, gp_hsh)
    act_name = act.act_name
    cur_act_name = act_name
    url = act.web&.url
    act_gp_id = act.gp_id

    if gp_hsh&.values&.compact&.present?
      ## Destroys acts based on duplicate gp_id.
      if !act_gp_id.present?
        binding.pry
        objs = [Act.find_by(gp_id: gp_hsh[:gp_id])].compact
        binding.pry
        if objs.any?
          binding.pry
          objs << act
          objs = objs.sort_by(&:id)
          act = objs.first
          binding.pry
          objs[1..-1].each {|act| act.destroy}
          binding.pry
        end
      end
      # valid_name = destroy_invalid_act_names(act, gp_hsh[:act_name], gp_hsh[:url])
      # return if !valid_name
    else
      binding.pry
      gp_hsh = {gp_sts: 'Invalid', gp_date: Time.now}
    end

    if gp_hsh[:url].present?
      web_hsh = gp_hsh.slice(:url)
      web = Web.find_or_create_by(web_hsh)
      act.web = web
    end

    act_hsh = gp_hsh.slice!(:url)
    act.update(act_hsh)
  end


end
