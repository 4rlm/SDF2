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
    @cut_off = 8.hours.ago
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

    # query = Act.select(:id).where(url: 'http://www.elmerhareford.com').pluck(:id)

    # temp_name = 'Dealer Inspire'
    # temp_name = 'DealerOn'
    # temp_name = 'DealerFire'
    # temp_name = 'DEALER eProcess'
    temp_name = 'Dealer Direct'
    # temp_name = 'DealerCar Search'

    query = Act.select(:id).where(temp_name: temp_name, cs_sts: 'Valid').
      where('cs_date < ? OR cs_date IS NULL', @cut_off).
      order("updated_at ASC").pluck(:id)

    print_query_stats(query)
    binding.pry
    return query
    ########## SPECIAL ABOVE ############

    ## Nil Sts Query ##
    query = Act.select(:id).where(page_sts: 'Valid', cs_sts: nil).
      order("updated_at ASC").pluck(:id)

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
        query.each { |id| act_obj = Act.find(id).update(cs_sts: 'Invalid') }
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


  #CALL: ContScraper.new.start_cont_scraper
  def template_starter(id)
    act_obj = Act.find(id)
    template = act_obj.temp_name
    puts template
    staff_link = act_obj.staff_link

    if !staff_link.present?
      act_obj.update(cs_sts: nil, page_sts: nil, staff_text: nil, staff_link: nil)
    else

      # if template = 'Cobalt' && staff_link.include?('landingpage')
      #   staff_link = "/meet-our-staff"
      # end

      full_staff_link = "#{act_obj.url}#{staff_link}"
      puts "full_staff_link: #{full_staff_link}"

      noko_hsh = start_noko(full_staff_link)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]
      act_update_hsh = { cs_date: Time.now }

      if err_msg.present?
        puts err_msg
        act_update_hsh[:cs_sts] = err_msg
        act_obj.update(act_update_hsh)
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
            cs_hsh_arr = CsSearchOptics.new.scrape_cont(noko_page, full_staff_link, act_obj)
          when "fusionZONE"
            cs_hsh_arr = CsFusionZone.new.scrape_cont(noko_page, full_staff_link, act_obj)
          # else
          #   cs_hsh_arr = CsStandardScraper.new.scrape_cont(noko_page, full_staff_link, act_obj)
          end
          update_db(act_obj, cs_hsh_arr)
        # else
          # cs_hsh_arr = CsStandardScraper.new.scrape_cont(noko_page, full_staff_link, act_obj)
          # update_db(act_obj, cs_hsh_arr)
        end
      end
    end

  end

  #CALL: ContScraper.new.start_cont_scraper
  def update_db(act_obj, cs_hsh_arr)
    cs_hsh_arr.flatten! if cs_hsh_arr.present?
    # cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?
    puts cs_hsh_arr

    if !cs_hsh_arr&.any?
      puts "\n\nNo results - check css classes on website.\n\n"
      act_obj.update(cs_sts: 'Invalid', cs_date: Time.now)
      return
    else
      act_id = act_obj.id
      cs_hsh_arr.each do |cs_hsh|
        cs_hsh[:act_id] = act_id
        cs_hsh[:cs_date] = Time.now

        # cont_obj = act_obj.conts.find_by("LOWER(full_name) LIKE LOWER('%#{cs_hsh[:full_name]}%')")
        cont_obj = act_obj.conts.find_by(full_name: cs_hsh[:full_name])
        cont_obj.present? ? cont_obj.update(cs_hsh) : cont_obj = Cont.create(cs_hsh)
      end
      act_obj.update(cs_sts: 'Valid', cs_date: Time.now)
    end
  end

end
