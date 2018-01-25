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
    @cut_off = 24.hours.ago
    # @prior_query_count = 0
    # @make_urlx = FALSE

    @gp = GpApi.new
    @formatter = Formatter.new
    @mig = Mig.new
  end


  def get_query
    ## Valid Sts Query ##
    val_sts_arr = ['Valid', nil]
    query = Act.select(:id).where(actx: FALSE, act_gp_sts: val_sts_arr).where('act_gp_date < ? OR act_gp_date IS NULL', @cut_off).order("updated_at ASC").pluck(:id)

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

    current_web_objs = cur_act_obj.webs
    if current_web_objs.count <= 1
      web_obj = current_web_objs&.first
    else
      web_obj = current_web_objs.where(urlx: FALSE).order("updated_at ASC")&.first
    end
    url = web_obj&.url

    if act_name.present? && !act_name.include?("Site Suspended")
      act_name = act_name&.gsub(/\s/, ' ')&.strip
      orig_act_name = act_name

      ## Remove Undesirable Words from Act Name before sending to Goog ##
      invalid_list = ["service", "services", "contract", "parts", "collision", "repairs", "repair", "credit", "loan", "department", "dept", "and", "safety", "safe", "equipment"]
      invalid_list += ["equip", "body", "shop", "wash", "detailing", "detail", "finance", "financial"]

      inval_hsh = @formatter.remove_invalids(act_name, invalid_list)
      act_name = inval_hsh[:act_name]

      ### GET GOOG RESULTS ###
      gp_hsh = @gp.get_spot(act_name, url)
      update_db(cur_act_obj, web_obj, gp_hsh)
    end
  end


  def update_db(cur_act_obj, web_obj, gp_hsh)
    act_name = cur_act_obj.act_name
    cur_act_name = act_name
    url = web_obj&.url

    if !gp_hsh&.values&.compact&.present?
      ## NO GOOG RESULTS ##
      puts "No Result from Google Places"
      cur_act_obj.update(act_gp_sts: 'Invalid', act_gp_date: Time.now)
      return
    else
      ## EXTRACT GOOG RESULTS HASH ##
      gp_sts_hsh = gp_hsh[:gp_sts_hsh]
      validity = gp_hsh[:gp_sts_hsh][:act_gp_sts]
      new_act_name = gp_hsh[:act_name]
      indus = gp_hsh[:indus]
      adr_hsh = gp_hsh[:adr]
      website = gp_hsh[:url]
      phone = gp_hsh[:phone]

      ### Act Save Results ###
      new_act_hsh = {act_gp_indus: indus, act_gp_sts: validity, act_name: new_act_name}
      current_act_attrs = { cop: cur_act_obj.cop, top: cur_act_obj.top, ward: cur_act_obj.ward }
      new_act_hsh = new_act_hsh.merge(current_act_attrs)
      new_act_hsh = new_act_hsh.merge(gp_sts_hsh)
      new_act_obj = @mig.save_comp_obj('act', {'act_name' => new_act_name}, new_act_hsh)

      ## Archive Current Act Obj if New Act Obj Created. ##
      cur_act_obj.update(actx: TRUE, act_fwd_id: new_act_obj.id, act_gp_sts: 'FWD', act_gp_date: Time.now) if cur_act_name != new_act_name

      ## Adr: Format and Create Obj
      basic_adr_hsh = adr_hsh.except(:adr_gp_sts)
      adr_obj = @mig.save_comp_obj('adr', basic_adr_hsh, adr_hsh) if adr_hsh&.values&.compact.present?
      @mig.create_obj_parent_assoc('adr', adr_obj, new_act_obj) if adr_obj.present?

      ## Phones: Format and Create Obj
      phone_obj = @mig.save_simp_obj('phone', {'phone' => phone}) if phone.present?
      @mig.create_obj_parent_assoc('phone', phone_obj, new_act_obj) if phone_obj.present?

  #############################
  #CALL: GpAct.new.start_gp_act
  #############################

      ## Website: Format and Create Obj
      web_hsh = {as_sts: validity, as_date: Time.now}
      new_web_obj = Web.find_or_create_by(url: website)
      new_web_obj.update(web_hsh)
      @mig.create_obj_parent_assoc('web', new_web_obj, new_act_obj) if new_web_obj.present?

      ## Update Existing Web Obj ##
      web_obj&.update(web_hsh)

      ### REPORTING RESULTS ###
      puts "\n\n====================="
      puts "O: #{cur_act_name}"
      puts "N: #{new_act_name}"
      puts "----------------------"
      puts "O: #{url}"
      puts "N: #{website}"
      puts "----------------------"
      puts "Ph: #{phone}"
      puts "Ind: #{indus}"

      if adr_obj
        puts "----------------------"
        puts "adr_gp_sts: #{adr_obj.adr_gp_sts}"
        puts "street: #{adr_obj.street}"
        puts "city: #{adr_obj.city}"
        puts "state: #{adr_obj.state}"
        puts "zip: #{adr_obj.zip}"
        puts "pin: #{adr_obj.pin}"
      end

      puts "=================\n\n\n"
      binding.pry
    end


  end



end
