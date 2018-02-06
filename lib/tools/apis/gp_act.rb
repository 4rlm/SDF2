#CALL: GpAct.new.start_gp_act
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'

class GpAct
  include IterQuery

  def initialize
    @dj_on = false
    @dj_count_limit = 0
    @workers = 4
    @obj_in_grp = 40
    @timeout = 10
    @count = 0
    @cut_off = 30.days.ago
    # @prior_query_count = 0
    # @make_urlx = FALSE
    @gp = GpApi.new
    @formatter = Formatter.new
    @mig = Mig.new
  end

  def get_query
    ## Nil Query
    query = Act.select(:id).where(actx: FALSE, gp_sts: nil, gp_id: nil).order("updated_at ASC").pluck(:id)
    ## Valid Sts Query ##
    query = Act.select(:id).where(actx: FALSE, gp_sts: 'Valid').order("updated_at ASC").pluck(:id) if !query.present?
    print_query_stats(query)
    return query
  end

  def print_query_stats(query)
    puts "\n\n===================="
    puts "@timeout: #{@timeout}\n\n"
    puts "\n\nQuery Count: #{query.count}"
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
    cur_act_obj = Act.find(id)
    act_name = cur_act_obj.act_name
    orig_act_name = act_name
    city = cur_act_obj.city
    state = cur_act_obj.state
    url = cur_act_obj.url

    ## Remove Undesirable Words from Act Name before sending to Goog ##
    invalid_list = ["service", "services", "contract", "parts", "collision", "repairs", "repair", "credit", "loan", "department", "dept", "and", "safety", "safe", "equipment"]
    invalid_list += ["equip", "body", "shop", "wash", "detailing", "detail", "finance", "financial"]
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

    gp_hsh = @gp.get_spot(act_name, url)
    update_db(cur_act_obj, gp_hsh)
  end




  #CALL: GpAct.new.start_gp_act
  def update_db(cur_act_obj, gp_hsh)
    act_name = cur_act_obj.act_name
    cur_act_name = act_name
    url = cur_act_obj.url

    if gp_hsh&.values&.compact&.present?
      if !cur_act_obj.gp_id.present?
        objs = [Act.find_by(gp_id: gp_hsh[:gp_id])].compact
        if objs.any?
          objs << cur_act_obj
          objs = objs.sort_by(&:id)
          cur_act_obj = objs.first
          objs[1..-1].each {|act| act.destroy}
        end
      end
      cur_act_obj.update(gp_hsh)
    else
      cur_act_obj.update(gp_sts: 'Invalid', gp_date: Time.now)
    end
  end


  ##Call: GpAct.new.delete_dups
  # def delete_dups
  #   dup_gp_ids = Act.select(:gp_id).group(:gp_id).having("count(*) > 1")&.pluck(:gp_id)&.compact
  #   if dup_gp_ids.present?
  #     dup_gp_ids.each do |gp_id|
  #       Act.where(gp_id: gp_id).order("created_at DESC")&.first&.destroy
  #     end
  #   end
  # end


end
