#CALL: ContScraper.new.start_cont_scraper
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'noko'

class ContScraper
  include IterQuery
  include Noko

  def initialize
    @dj_on = false
    @dj_count_limit = 0
    @workers = 4
    @obj_in_grp = 40
    @timeout = 60
    @count = 0
    @cut_off = 12.hours.ago
    @make_urlx = FALSE
    @formatter = Formatter.new
    @mig = Mig.new
    @cs_helper = CsHelper.new
  end

  def get_query
    # Dominion, eBizAutos, Dealer Spike, DealerPeak

    ########## SPECIAL BELOW ############
    ## TRYING TO GET TEMPS OF NON-MAJOR ONES, GENERAL SCRAPERS!
    ## Invalid Sts Query ##
    # @cut_off = 8.hours.ago


    # temp_name = 'Dealer.com'
    # temp_name = 'Cobalt'
    # temp_name = 'Dealer Inspire'
    # temp_name = 'DealerOn'
    # temp_name = 'DealerFire'
    # temp_name = 'DEALER eProcess'
    # temp_name = 'Dealer Direct'

    # query = Act.select(:id).where(url: 'http://www.elmerhareford.com').pluck(:id)
    # query = Act.select(:id).where(temp_name: temp_name, cs_sts: 'Valid').
    #   where('cs_date < ? OR cs_date IS NULL', @cut_off).
    #   order("updated_at ASC").pluck(:id)
    #
    # print_query_stats(query)
    # binding.pry
    # return query
    ########## SPECIAL ABOVE ############
    temp_names = ['Dealer.com', 'Cobalt', 'Dealer Inspire', 'DealerOn', 'DealerFire', 'DEALER eProcess', 'Dealer Direct']

    ## Nil Sts Query ##
    query = Act.select(:id).where(temp_name: temp_names, page_sts: 'Valid', cs_sts: nil).
      order("updated_at ASC").pluck(:id)

    print_query_stats(query)
    return query

    ## Valid Sts Query ##
    query = Act.select(:id).where(cs_sts: 'Valid').
      where('cs_date < ? OR cs_date IS NULL', @cut_off).
      order("updated_at ASC").pluck(:id) if !query.any?

    ## Error Sts Query ##
    if !query.any?
      err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
      query = Act.select(:id).where(cs_sts: err_sts_arr).
      order("updated_at ASC").pluck(:id)

      @timeout = 60

      if query.any? && @make_urlx
        query.each { |id| act = Act.find(id).update(cs_sts: 'Invalid') }
        query = [] ## reset
        @make_urlx = FALSE
      elsif query.any?
        @make_urlx = TRUE
      end
    end

    print_query_stats(query)
    return query
  end

  def print_query_stats(query)
    puts "\n\n===================="
    puts "@timeout: #{@timeout}\n\n"
    puts "\n\nQuery Count: #{query.count}"
  end

  def start_cont_scraper
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



  ### WORK BEGINS HERE !!!! ####


  #CALL: ContScraper.new.start_cont_scraper
  def template_starter(id)
    act = Act.find(id)
    template = act.temp_name
    link_objs = act.links


    link_objs.each do |link_obj|
      act_link_obj = act.act_links.find_by(link_id: link_obj)
      staff_link = link_obj.staff_link
      cs_hsh_arr = []

      if !staff_link.present?
        puts "\n\nNo Staff Link!!\n\n"
        ## Makes Act cs_sts: nil, but can change back to 'Valid' if more links behind.
        act.update(cs_sts: err_msg, cs_date: Time.now)
        act_link_obj.update(link_sts: nil, cs_count: 0)
      else
        full_staff_link = "#{act.url}#{staff_link}"
        puts "full_staff_link: #{full_staff_link}"

        noko_hsh = start_noko(full_staff_link)
        noko_page = noko_hsh[:noko_page]
        err_msg = noko_hsh[:err_msg]
        act_update_hsh = { cs_date: Time.now }

        if err_msg.present?
          puts err_msg
          ## Makes Act cs_sts: error, but can change back to 'Valid' if more links behind.
          act.update(cs_sts: err_msg, cs_date: Time.now)
          act_link_obj.update(link_sts: err_msg, cs_count: 0)
        elsif noko_page.present?
          if template.present?
            case template
            when "Dealer.com" ## Good
              cs_hsh_arr = CsDealerCom.new.scrape_cont(noko_page)
            when "Cobalt" ## Good - alpha
              cs_hsh_arr = CsCobalt.new.scrape_cont(noko_page)
            when "DealerOn" ## Good - alpha
              cs_hsh_arr = CsDealeron.new.scrape_cont(noko_page)
            when "Dealer Direct" ## Good - alpha
              cs_hsh_arr = CsDealerDirect.new.scrape_cont(noko_page)
            when "Dealer Inspire" ## Good - alpha
              cs_hsh_arr = CsDealerInspire.new.scrape_cont(noko_page)
            when "DealerFire" ## Good - alpha
              cs_hsh_arr = CsDealerfire.new.scrape_cont(noko_page)
            when "DEALER eProcess" ## Good - alpha
              cs_hsh_arr = CsDealerEprocess.new.scrape_cont(noko_page)
            when "Search Optics"
              cs_hsh_arr = CsSearchOptics.new.scrape_cont(noko_page, full_staff_link, act)
            when "fusionZONE"
              cs_hsh_arr = CsFusionZone.new.scrape_cont(noko_page, full_staff_link, act)
            # else
            #   cs_hsh_arr = CsStandardScraper.new.scrape_cont(noko_page, full_staff_link, act)
            end
            update_db(act, cs_hsh_arr, link_obj, act_link_obj)
          # else
            # cs_hsh_arr = CsStandardScraper.new.scrape_cont(noko_page, full_staff_link, act)
            # update_db(act, cs_hsh_arr, link_obj, act_link_obj)
          end
        end
      end
    end
  end

  #CALL: ContScraper.new.start_cont_scraper
  def update_db(act, cs_hsh_arr, link_obj, act_link_obj)
    cs_hsh_arr.flatten! if cs_hsh_arr.present?
    cs_count_arr = []
    cs_total_arr = []
    puts cs_hsh_arr

    if !cs_hsh_arr&.any?
      puts "\n\nVALID LINK, BUT NO SCRAPED CONTACTS.\n\n"
      act_link_obj.update(link_sts: 'Valid', cs_count: 0)
    else
      puts "\n\nVALID LINK AND SCRAPED CONTACTS!!\n\n"
      act_id = act.id

      cs_hsh_arr.each do |cs_hsh|
        puts cs_hsh.inspect
        cs_hsh[:act_id] = act_id
        cs_hsh[:cs_date] = Time.now

        cont_obj = act.conts.find_by(full_name: cs_hsh[:full_name])
        cont_obj.present? ? cont_obj.update(cs_hsh) : cont_obj = Cont.create(cs_hsh)
        cs_count_arr << cont_obj.id
      end

      ## Calculate Scraped Contacts Count from each link.
      cs_total_arr.flatten!
      cs_count_arr&.uniq!
      cs_count = cs_count_arr.count
      cs_total_arr << cs_count_arr
      act_link_obj.update(link_sts: 'Valid', cs_count: cs_count)
    end

    ## Final Update Act
    cs_total_arr.flatten!
    cs_total_arr&.uniq!
    cs_total = cs_total_arr.count
    cs_total > 0 ? cs_sts = 'Valid' : cs_sts = 'Invalid'
    act.update(cs_sts: cs_sts, cs_date: Time.now)
  end

end
