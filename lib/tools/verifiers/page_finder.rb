#CALL: PageFinder.new.start_page_finder

# require 'open-uri'
# require 'mechanize'
# require 'uri'
# require 'nokogiri'
# require 'socket'
# require 'httparty'
# require 'delayed_job'
# require 'indexer_helper/rts/dealerfire_rts'
# require 'indexer_helper/rts/cobalt_rts'
# require 'indexer_helper/rts/dealer_inspire_rts'
# require 'indexer_helper/rts/dealeron_rts'
# require 'indexer_helper/rts/dealer_com_rts'
# require 'indexer_helper/rts/dealer_direct_rts'
# require 'indexer_helper/rts/dealer_eprocess_rts'
# require 'indexer_helper/rts/dealercar_search_rts'
# # require 'indexer_helper/page_finder_original'  # ### CAN REMOVE THIS.  HAS BEEN REPLACED.
# require 'indexer_helper/rts/rts_helper'
# require 'indexer_helper/rts/rts_manager'
# require 'indexer_helper/unknown_template' # Unknown template's info scraper
# require 'indexer_helper/helper' # All helper methods for indexer_service
# require 'servicers/url_verifier' # Bridges UrlRedirector Module to indexer/services.
# require 'curb' #=> for url_redirector
##################################################

require 'complex_query_iterator'
# require 'net_verifier'
require 'noko'

#CALL: PageFinder.new.start_page_finder
class PageFinder
  include ComplexQueryIterator
  # include NetVerifier
  include Noko

  def initialize
    ## Below are Settings for ComplexQueryIterator Module.
    @timeout = 10
    @dj_count_limit = 20 #=> Num allowed before releasing next batch.
    @workers = 4 #=> Divide format_query_results into groups of x.
  end

  def start_page_finder
    # query = Web.where(temp_sts: 'valid').order("updated_at ASC")[201..210].pluck(:id)
    query = Web.where(temp_sts: 'valid').order("updated_at ASC")[150..250].pluck(:id)


    obj_in_grp = 20
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

    # iterate_query(query) # via ComplexQueryIterator
    query.each { |id| template_starter(id) }
  end


  def template_starter(id)
    web_obj = Web.find(id)
    noko_hsh = start_noko(web_obj.url)
    noko_page = noko_hsh[:noko_page]
    err_msg = noko_hsh[:err_msg]
    # web_update_hsh = { staff_link_sts: nil, loc_link_sts: nil, staff_text_sts: nil, loc_text_sts: nil, link_text_date: Time.now }
    web_update_hsh = { link_text_date: Time.now }

    if err_msg.present?
      puts err_msg
      binding.pry
      web_update_hsh.merge!({staff_link_sts: err_msg, loc_link_sts: err_msg, staff_text_sts: err_msg, loc_text_sts: err_msg})
      web_obj.update_attributes(web_update_hsh)
    elsif noko_page.present?

      staff_hsh = parse_page(web_obj, noko_page, "staff")
      staff_link = staff_hsh[:link]
      staff_text = staff_hsh[:text]
      staff_link.present? ? staff_link_sts = 'valid' : staff_link_sts = 'invalid'
      staff_text.present? ? staff_text_sts = 'valid' : staff_text_sts = 'invalid'

      loc_hsh = parse_page(web_obj, noko_page, "location")
      loc_link = loc_hsh[:link]
      loc_text = loc_hsh[:text]
      loc_link.present? ? loc_link_sts = 'valid' : loc_link_sts = 'invalid'
      loc_text.present? ? loc_text_sts = 'valid' : loc_text_sts = 'invalid'

      web_update_hsh.merge!({staff_link_sts: staff_link_sts, loc_link_sts: loc_link_sts, staff_text_sts: staff_text_sts, loc_text_sts: loc_text_sts})
      ###########################

       # "/meetourstaff.aspx", link_type: "staff", link_sts: nil,

      # parse_page(noko_page, "location")
      # loc_link_sts: nil, loc_text_sts: nil,
    end

    update_db(id, web_obj, web_update_hsh, staff_hsh, loc_hsh)
  end


  def update_db(id, web_obj, web_update_hsh, staff_hsh, loc_hsh)
    puts "\n\n==================\n#{web_update_hsh.to_yaml}\n#{staff_hsh.to_yaml}\n#{loc_hsh.to_yaml}\n"
    binding.pry



    # temp_obj = Template.find_by(template_name: new_temp) if new_temp.present?
    # Migrator.new.create_obj_parent_assoc('template', temp_obj, web_obj) if temp_obj.present?
    # web_obj.update_attributes(temp_sts: temp_sts, temp_date: Time.now, updated_at: Time.now)
    # tf_starter if id == @last_id
  end

  # def update_db(status, text, href, link, mode)
  #   binding.pry
  #   # Clean the Data before updating database
  #   # clean = record_cleaner(text, href, link)
  #   # text, href, link = clean[:text], clean[:href], clean[:link]
  #
  #   if mode == "location"
  #     # @indexer.update_attributes(indexer_status: "PageFinder", loc_status: status, location_url: link, location_text: text, page_finder_date: DateTime.now) if @indexer != nil
  #   elsif mode == "staff"
  #     # @indexer.update_attributes(indexer_status: "PageFinder", stf_status: status, staff_url: link, staff_text: text, page_finder_date: DateTime.now) if @indexer != nil
  #   end
  # end



  ########################################
  #CALL: PageFinder.new.start_page_finder
  ########################################

  def parse_page(web_obj, noko_page, mode)
    list = text_href_list(web_obj, mode)
    text_list = list[:text_list]
    parsed_hsh = {}

    text_list.each do |text|
      text = format_href(text)
      noko_page.links.each do |noko_link|
        link_text = format_href(noko_link&.text)
        if link_text&.include?(text)
          formatted_link = Formatter.new.format_link(web_obj.url, noko_link&.href)
          formatted_text = noko_link&.text&.strip

          if formatted_text.present? && formatted_link.present?
            parsed_hsh[:text] = formatted_text
            parsed_hsh[:link] = formatted_link
            return parsed_hsh
          end
        end
      end
    end

    if parsed_hsh.values.compact.empty?
      href_list = list[:href_list]
      href_list.each do |href|
         noko_page.links.each do |noko_link|
          link_href = format_href(noko_link&.href)
          if link_href&.include?(href)
            formatted_link = Formatter.new.format_link(web_obj.url, noko_link&.href)
            formatted_text = noko_link&.text&.strip

            if formatted_text.present? && formatted_link.present?
              parsed_hsh[:text] = formatted_text
              parsed_hsh[:link] = formatted_link
              return parsed_hsh
            end
          end
        end
      end
    end

    return parsed_hsh
  end


  ##################################################
  ############ HELPER METHODS BELOW ################
  ##################################################


  # def to_regexp(arr)
  #   arr.map! { |str| format_href(str) }.uniq!
  #   arr.delete("meetourdepartments")
  #   arr << "meetourdepartments" ## Should be last in arr.
  #   arr.map! { |str| str = Regexp.new(str) }
  #   return arr
  # end


  def format_href_list(arr)
    arr.map! { |str| format_href(str) }.uniq!
    arr.delete("meetourdepartments")
    arr << "meetourdepartments" ## Should be last in arr.
    return arr
  end

  def format_href(href)
    if href.present?
      href = href.downcase
      href = href.gsub(/[^A-Za-z0-9]/, '')
      return href if href.present?
    end
  end


  def text_href_list(web_obj, mode)
    if mode == "staff"
      text = "staff_text"
      href = "staff_href"
      term = web_obj.templates&.order("updated_at DESC")&.first&.template_name
      special_templates = ["Cobalt", "Dealer Inspire", "DealerFire"]
      term = 'general' if !special_templates.include?(term)
    elsif mode == "location"
      text = "loc_text"
      href = "loc_href"
      term = "general"
    end

    text_list = Term.where(sub_category: text).where(criteria_term: term).map(&:response_term)
    # href_list = Term.where(sub_category: href).where(criteria_term: term).map(&:response_term)
    # href_list = to_regexp(Term.where(sub_category: href).where(criteria_term: term).map(&:response_term))
    href_list = format_href_list(Term.where(sub_category: href).where(criteria_term: term).map(&:response_term))

    return {text_list: text_list, href_list: href_list}
    # list = text_href_list(web_obj, mode)
    # text_list = list[:text_list]
  end



end
