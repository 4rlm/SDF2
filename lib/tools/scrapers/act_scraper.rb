#######################################
#CALL: ActScraper.new.start_act_scraper
#######################################

require 'complex_query_iterator'
require 'noko'


#CALL: ActScraper.new.start_act_scraper
class ActScraper
  include ComplexQueryIterator
  include Noko

  def initialize
    @timeout = 10
    @dj_count_limit = 25 #=> Num allowed before releasing next batch.
    @workers = 4 #=> Divide format_query_results into groups of x.
  end


  def start_act_scraper
    query = Web.where(temp_sts: 'valid', acs_sts: nil).order("updated_at ASC").pluck(:id)

    obj_in_grp = 30
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

    # iterate_query(query) # via ComplexQueryIterator
    query.each { |id| template_starter(id) }
  end


  #######################################
  #CALL: ActScraper.new.start_act_scraper
  #######################################

  def template_starter(id)
    web_obj = Web.find(id)
    noko_hsh = start_noko(web_obj.url)
    noko_page = noko_hsh[:noko_page]
    err_msg = noko_hsh[:err_msg]
    web_update_hsh = { acs_date: Time.now }

    if err_msg.present?
      puts err_msg
      web_update_hsh[:acs_sts] = err_msg
      web_obj.update_attributes(web_update_hsh)
    elsif noko_page.present?
      template = web_obj&.templates&.order("updated_at DESC")&.first&.template_name
      term = Term.where(response_term: template).where.not(mth_name: nil)&.first&.mth_name

      if term.present?
        case term
        when "as_dealer_com"
          as_hsh = AsDealerCom.new.scrape_act(noko_page, web_obj)
        when "as_cobalt"
          as_hsh = AsCobalt.new.scrape_act(noko_page, web_obj)
        when "as_dealeron"
          as_hsh = AsDealeron.new.scrape_act(noko_page, web_obj)
        when "as_dealercar_search"
          as_hsh = AsDealercarSearch.new.scrape_act(noko_page, web_obj)
        when "as_dealer_direct"
          as_hsh = AsDealerDirect.new.scrape_act(noko_page, web_obj)
        when "as_dealer_inspire"
          as_hsh = AsDealerInspire.new.scrape_act(noko_page, web_obj)
        when "as_dealerfire"
          as_hsh = AsDealerfire.new.scrape_act(noko_page, web_obj)
        when "as_dealer_eprocess"
         as_hsh =  AsDealerEprocess.new.scrape_act(noko_page, web_obj)
        else
          as_hsh = AsMeta.new.scrape_act(noko_page, web_obj)
        end
        update_db(web_obj, as_hsh)
      else
        as_hsh = AsMeta.new.scrape_act(noko_page, web_obj)
        update_db(web_obj, as_hsh)
      end

    end

  end


  #######################################
  #CALL: ActScraper.new.start_act_scraper
  #######################################


  def update_db(web_obj, as_hsh)
    formatter = Formatter.new
    migrator = Migrator.new
    puts as_hsh.to_yaml

    ## Act: Format and Create Obj
    act_name = formatter.format_act_name(as_hsh[:org]) if as_hsh[:org].present?
    act_name = 'unidentified' if !act_name.present?
    act_hsh = {act_src: 'Bot', act_name: act_name}
    act_obj = migrator.save_complex_obj('act', {'act_name' => act_name}, act_hsh)
    migrator.create_obj_parent_assoc('web', web_obj, act_obj) if act_obj.present?

    ## Adr: Format and Create Obj
    adr_hsh = { street: as_hsh[:street], city: as_hsh[:city], state: as_hsh[:state], zip: as_hsh[:zip] }
    adr_hsh = formatter.format_adr_hsh(adr_hsh) if adr_hsh.values.compact.present?
    adr_obj = migrator.save_simple_obj('adr', adr_hsh) if adr_hsh.present?
    migrator.create_obj_parent_assoc('adr', adr_obj, act_obj) if adr_obj.present?

    ## Phones: Format and Create Obj
    as_hsh[:as_phones] << as_hsh[:phone] if as_hsh[:as_phones].present?
    phones = as_hsh[:as_phones].map { |phone|  formatter.validate_phone(as_hsh[:phone]) }.uniq.sort if as_hsh[:as_phones].any?

    phones&.each do |phone|
      phone_obj = migrator.save_simple_obj('phone', {'phone' => phone}) if phone.present?
      migrator.create_obj_parent_assoc('phone', phone_obj, act_obj) if phone_obj.present?
    end

    puts "================="
    puts act_hsh.to_yaml
    puts adr_hsh.to_yaml
  end



  # phone = Formatter.new.validate_phone(phone)
  # @manager.address_formatter(org, street, city, state, zip, phone, as_phones, web_obj)


end
