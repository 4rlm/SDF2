#######################################
#CALL: GpAct.new.start_gp_act
#######################################
require 'iter_query'

class GpAct
  include IterQuery

  def initialize
    @dj_on = true
    @dj_count_limit = 30
    @workers = 4
    @obj_in_grp = 50
    @timeout = 10
    @count = 0
    @cut_off = 55.hours.ago
    @prior_query_count = 0

    @gp = GpApi.new
    @formatter = Formatter.new
    @mig = Mig.new
  end

  def get_query
    @count += 1
    @timeout *= @count
    puts "\n\n===================="
    # delete_fwd_web_dups ## Removes duplicates
    puts "@count: #{@count}"
    puts "@timeout: #{@timeout}\n\n"
    ####################################
    # act_name: "AutoNation in Fort Lauderdale, FL", actx: false, cop: true, top: nil, ward: nil, act_fwd_id: nil, act_gp_sts: nil, act_gp_date: nil, act_gp_id: nil, act_gp_indus: nil

    val_sts_arr = ['Valid', nil]
    query = Act.select(:id).
      where(actx: FALSE, act_gp_sts: val_sts_arr).
      where('act_gp_date < ? OR act_gp_date IS NULL', @cut_off).
      order("updated_at ASC").
      pluck(:id)

    puts "\n\nQ1-Count: #{query.count}"
    return query
  end

  def start_gp_act
    query = get_query
    query_count = query.count
    while query_count != @prior_query_count
      setup_iterator(query)
      @prior_query_count = query_count
      break if (query_count == get_query.count) || @count > 4
      start_gp_act
    end
  end

  def setup_iterator(query)
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
    @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }
  end



  ##### CONTINUE WORKING BELOW #####



  def template_starter(id)
    cur_act_obj = Act.find(id)
    update_db(cur_act_obj)

    if act_obj.present?
      # web_url = web_obj.url
      # noko_hsh = start_noko(web_url)
      # page = noko_hsh[:noko_page]
      # err_msg = noko_hsh[:err_msg]
      #
      # if err_msg.present?
      #   puts err_msg
      #   tmp_sts = err_msg
      #   new_temp = 'Error: Search'
      # end
      #
      # if page.present?
      #   new_temp = Term.where(category: "find_temp").where(sub_category: "at_css").select { |term| term.response_term if page&.at_css('html')&.text&.include?(term.criteria_term) }&.first&.response_term
      #   new_temp.present? ? tmp_sts = 'Valid' : tmp_sts = 'Unidentified'
      # end

      update_db(id, web_obj, new_temp, tmp_sts)
    end
  end


  def template_starter(id)
    cur_act_obj = Act.find(id)
    update_db(cur_act_obj)
  end


  def update_db(cur_act_obj)
    act_name = cur_act_obj.act_name
    cur_act_name = act_name
    # web_obj = cur_act_obj.webs.where(urlx: FALSE).order("updated_at DESC")&.first
    url = web_obj&.url

    ### KEEP BELOW FOR LATER - IF WEB QUERY USED ###
    # act_name = acts.last.act_name
    # act_name = acts.where.not(crma: nil)&.first&.act_name
    # src_ranking = ["CRM", "Cop", "Bot", "GEO", "Search", nil]
    # act_name = acts.where(act_src: src_ranking)&.first&.act_name if !act_name.present?
    # sts_ranking = ["Imported", "RT Result", "Geo Result", "MS Result", "IMG Search", "RT Error", nil]
    # act_name = acts.where(act_sts: sts_ranking)&.first&.act_name if !act_name.present?

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
        new_act_hsh = {act_gp_indus: indus, act_sts: validity, act_name: new_act_name}
        new_act_hsh[:act_src] = 'Bot' if !Act.exists?(act_name: new_act_name)
        new_act_hsh = new_act_hsh.merge(gp_sts_hsh) if gp_hsh&.values&.compact&.present?
        new_act_obj = @mig.save_comp_obj('act', {'act_name' => new_act_name}, new_act_hsh)
        # @mig.create_obj_parent_assoc('web', web_obj, new_act_obj) if new_act_obj.present? && web_obj.present?

        ## Archive Current Act Obj if New Act Obj Created. ##
        if cur_act_name != new_act_name
          cur_act_obj.update(act_fwd_id: new_act_obj.id, act_sts: 'FWD', act_gp_sts: 'FWD', act_gp_date: Time.now)
        end
        # new_act_obj
        # cur_act_obj
        binding.pry

        ## Adr: Format and Create Obj
        basic_adr_hsh = adr_hsh.except(:adr_gp_sts)
        adr_obj = @mig.save_comp_obj('adr', basic_adr_hsh, adr_hsh) if adr_hsh&.values&.compact.present?
        @mig.create_obj_parent_assoc('adr', adr_obj, new_act_obj) if adr_obj.present?

        ## Phones: Format and Create Obj
        phone_obj = @mig.save_simp_obj('phone', {'phone' => phone}) if phone.present?
        @mig.create_obj_parent_assoc('phone', phone_obj, new_act_obj) if phone_obj.present?

        ## Website: Format and Create Obj
        web_hsh = {as_sts: validity, as_date: Time.now}
        new_web_obj = @mig.save_comp_obj('web', {'url' => website}, web_hsh) if website.present?
        @mig.create_obj_parent_assoc('web', new_web_obj, new_act_obj) if new_web_obj.present?

        ## Update Existing Web Obj ##
        cur_act_urls = cur_act_obj.webs.map(&:url)
        contains_url = cur_act_urls.any? {|url| url == website } if web_obj && cur_act_urls.any?
        web_obj&.update(web_hsh) if contains_url



        ### REPORTING RESULTS ###
        puts "\n\n====================="
        puts "O: #{cur_act_name}"
        puts "N: #{new_act_name}"
        puts "----------------------"
        puts "O: #{url}"
        puts "N: #{website}"
        puts "----------------------"
        puts "N: #{phone}"
        puts "I: #{indus}"

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
      end

    end


  end


end
