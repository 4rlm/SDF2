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
    @dj_count_limit = 5
    @workers = 4
    @obj_in_grp = 40
    @timeout = 5
    @count = 0
    @cut_off = 30.days.ago
    @make_urlx = FALSE
    @formatter = Formatter.new
    @mig = Mig.new
    @cs_helper = CsHelper.new
  end

  def get_query
    ## Nil Sts Query ##
    query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: 'Valid', temp_name: 'Dealer Inspire', cs_sts: nil).order("updated_at ASC").pluck(:id)

    ## Valid Sts Query ##
    val_sts_arr = ['Valid']
    query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: 'Valid', cs_sts: val_sts_arr).where('cs_date < ? OR cs_date IS NULL', @cut_off).order("updated_at ASC").pluck(:id) if !query.any?

    ## Error Sts Query ##
    if !query.any?
      err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
      query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: 'Valid', cs_sts: err_sts_arr).order("updated_at ASC").pluck(:id)
      @timeout = 60

      if query.any? && @make_urlx
        query.each { |id| act_obj = Act.find(id).update(urlx: TRUE) }
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
    staff_link = act_obj.staff_link

    if staff_link.present?

      if staff_link.include?('card')
        staff_link = '/MeetOurDepartments'
        act_obj.update(staff_link: staff_link)
        binding.pry
      end

      # if staff_link.include?('miscpage')
      #   staff_link = '/Staff'
      #   act_obj.update(staff_link: staff_link)
      #   binding.pry
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
        template = act_obj.temp_name

        if template.present?
          case template
          when "Dealer.com"
            cs_hsh_arr = CsDealerCom.new.scrape_cont(noko_page)
          when "Cobalt"
            cs_hsh_arr = CsCobalt.new.scrape_cont(noko_page)
          when "DealerOn"
            cs_hsh_arr = CsDealeron.new.scrape_cont(noko_page)
          when "Dealer Direct"
            cs_hsh_arr = CsDealerDirect.new.scrape_cont(noko_page)
          when "Dealer Inspire"
            cs_hsh_arr = CsDealerInspire.new.scrape_cont(noko_page)
          when "DealerFire"
            cs_hsh_arr = CsDealerfire.new.scrape_cont(noko_page)
          when "DEALER eProcess"
            cs_hsh_arr = CsDealerEprocess.new.scrape_cont(noko_page)
          else
            cs_hsh_arr = CsStandardScraper.new.scrape_cont(noko_page)
          end
          update_db(act_obj, cs_hsh_arr)
        else
          cs_hsh_arr = CsStandardScraper.new.scrape_cont(noko_page)
          update_db(act_obj, cs_hsh_arr)
        end
      end
    else
      ## If No Staff Link Exists ##
    end

  end

  #CALL: ContScraper.new.start_cont_scraper
  def update_db(act_obj, cs_hsh_arr)
    cs_hsh_arr = @cs_helper.prep_create_staffer(cs_hsh_arr) if cs_hsh_arr.any?
    puts cs_hsh_arr

    if !cs_hsh_arr.any?
      binding.pry
      act_obj.update(cs_sts: 'Invalid', cs_date: Time.now)
      return
    else
      act_id = act_obj.id
      cs_hsh_arr.each do |cs_hsh|
        cs_hsh[:act_id] = act_id
        cont_obj = Cont.find_by(act_id: act_id, full_name: cs_hsh[:full_name], email: cs_hsh[:email])
        cont_obj.present? ? cont_obj.update(cs_hsh) : cont_obj = Cont.create(cs_hsh)
      end
      act_obj.update(cs_sts: 'Valid', cs_date: Time.now)
    end
  end


end
