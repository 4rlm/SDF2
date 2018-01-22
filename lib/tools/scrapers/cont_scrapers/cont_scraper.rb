#######################################
#CALL: ContScraper.new.start_cont_scraper
#######################################

require 'iter_query'
require 'noko'


#CALL: ContScraper.new.start_cont_scraper
class ContScraper
  include IterQuery
  include Noko


  def initialize
    @timeout = 10
    @dj_count_limit = 25 #=> Num allowed before releasing next batch.
    @workers = 4 #=> Divide format_query_results into groups of x.
  end


  def start_cont_scraper
    # query = Web.where(cs_sts: nil).order("updated_at ASC").pluck(:id)
    # query = Web.where(slink_sts: 'Valid', cs_sts: nil).order("updated_at ASC").pluck(:id)
    query = Web.where(slink_sts: 'PF Result').order("updated_at ASC").pluck(:id)
    # query = Web.where(tmp_sts: 'Valid', cs_sts: nil).order("updated_at ASC").pluck(:id)

    obj_in_grp = 30
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

    # iterate_query(query) # via IterQuery
    query.each { |id| template_starter(id) }
  end


  def template_starter(id)
    web_obj = Web.find(id)
    link_obj = web_obj&.links&.order("updated_at DESC")&.first
    staff_link = "#{web_obj.url}#{link_obj.link}" if link_obj&.link_type == "staff"

    if staff_link.present?
      ### Above queries will be simpler in few hours after template and page finder have completed running.  Won't need to have this if/else.  Can just run query at top level based on: query = Web.where(tmp_sts: 'Valid', slink_sts: 'Valid').order("updated_at ASC").pluck(:id)

      noko_hsh = start_noko(staff_link)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]
      web_update_hsh = { cs_date: Time.now }

      if err_msg.present?
        binding.pry
        puts err_msg
        web_update_hsh[:as_sts] = err_msg
        # web_obj.update(web_update_hsh)
      elsif noko_page.present?
        binding.pry

        template = web_obj&.templates&.order("updated_at DESC")&.first&.temp_name
        # term = Term.where(response_term: template).where.not(mth_name: nil)&.first&.mth_name

        if template.present?
          binding.pry

          case template
          when "Dealer.com"
            CsDealerCom.new.scrape_cont(noko_page, web_obj)
          when "Cobalt"
            CsCobalt.new.scrape_cont(noko_page, web_obj)
          when "DealerOn"
            CsDealeron.new.scrape_cont(noko_page, web_obj)
          when "Dealer Direct"
            CsDealerDirect.new.scrape_cont(noko_page, web_obj)
          when "Dealer Inspire"
            CsDealerInspire.new.scrape_cont(noko_page, web_obj)
          when "DealerFire"
            CsDealerfire.new.scrape_cont(noko_page, web_obj)
          when "DEALER eProcess"
            CsDealerEprocess.new.scrape_cont(noko_page, web_obj)
          else
            CsStandardScraper.new.scrape_cont(noko_page, web_obj)
          end
          # update_db(web_obj, as_hsh)
        else
          # as_hsh = AsMeta.new.scrape_act(noko_page, web_obj)
          # update_db(web_obj, as_hsh)
        end

      end

    else
      ## If No Staff Link Exists ##
      binding.pry
    end


  end

end
