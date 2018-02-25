#CALL: GpStart.new.start_gp_act
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'gp_run'

# %w{gp_run iter_query}.each { |x| require x }


class GpStart
  include IterQuery
  include GpRun

  def initialize
    @dj_on = false
    @dj_count_limit = 0
    @dj_workers = 4
    @obj_in_grp = 40
    @dj_refresh_interval = 10
    @db_timeout_limit = 60
    @count = 0
    @cut_off = 5.days.ago
    @formatter = Formatter.new
    @mig = Mig.new
    @return_multiple_spots = true

    @client = GooglePlaces::Client.new('AIzaSyDX5Sn2mNT1vPh_MyMnNOH5YL4cIWaB3s4')
    @formatter = Formatter.new
    @query_start_time = Time.now
  end

  def get_query

    ## Multiple Spots Query
    query = Act.select(:id)
      .where(gp_sts: ['Valid', nil])
      .where.not(city: nil, state: nil, zip: nil)
      .where('gp_date < ? OR gp_date IS NULL', @cut_off)
      .order("id ASC")[0..0].pluck(:id)


    # ## ## Valid Sts Query ##
    # val_sts_arr = ['Valid', nil]
    # query = Act.select(:id)
    #   .where(gp_sts: val_sts_arr)
    #   .where('gp_date < ? OR gp_date IS NULL', @cut_off)
    #   .order("id ASC").pluck(:id)

    ## ## Skipped Sts Query ##
    if !query.any?
      query = Act.select(:id)
        .where(gp_sts: 'Skipped')
        .where('gp_date < ? OR gp_date IS NULL', @cut_off)
        .order("id ASC").pluck(:id)

      @return_multiple_spots = false
    end

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

    gp_hsh_arr = get_spot(act, act_name)
    gp_hsh_arr.each { |gp_hsh| update_db(act, gp_hsh) } if gp_hsh_arr&.any?

    act.reload
    act.update(gp_sts: 'Skipped') if (act.gp_date < @query_start_time)
  end


  #CALL: GpStart.new.start_gp_act
  def update_db(act, gp_hsh)

    if @return_multiple_spots == false
      act_gp_id = act.gp_id
      if gp_hsh&.values&.compact&.present?
        ## Destroys acts based on duplicate gp_id.
        if !act_gp_id.present?
          objs = [Act.find_by(gp_id: gp_hsh[:gp_id])].compact
          if objs.any?
            objs << act
            objs = objs.sort_by(&:id)
            act = objs.first
            objs[1..-1].each {|act| act.destroy}
          end
        end
      else
        gp_hsh = {gp_sts: 'Invalid', gp_date: Time.now}
      end
    elsif @return_multiple_spots == true
      act = Act.find_or_create_by(gp_id: gp_hsh[:gp_id])
      # (@updated_original_act = true) if (act.id == @original_act_id)
    end

    if gp_hsh[:url].present?
      gp_url = gp_hsh[:url]
      http_s_hsh = make_http_s(gp_url)
      web = Web.find_by(url: http_s_hsh[:https])
      web = Web.find_by(url: http_s_hsh[:http]) if !web.present?
      web = Web.create(url: gp_url) if !web.present?
    end

    act.web = web if (web.present? && (act.web != web))
    url = act.web&.url
    act_hsh = gp_hsh.slice!(:url)
    act.update(act_hsh)
  end


  ## Helper Methods Below ###

  # Call: GpStart.new.make_http_s('gp_url')
  def make_http_s(gp_url)
    if gp_url.present?
      uri = URI(gp_url)
      if uri.present?
        http_s_hsh = { http: "http://#{uri.host}", https: "https://#{uri.host}" }
        return http_s_hsh
      end
    end
  end


end