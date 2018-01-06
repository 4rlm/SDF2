# #CALL: PageFinder.new.start_page_finder
#
# # require 'open-uri'
# # require 'mechanize'
# # require 'uri'
# # require 'nokogiri'
# # require 'socket'
# # require 'httparty'
# # require 'delayed_job'
# # require 'indexer_helper/rts/dealerfire_rts'
# # require 'indexer_helper/rts/cobalt_rts'
# # require 'indexer_helper/rts/dealer_inspire_rts'
# # require 'indexer_helper/rts/dealeron_rts'
# # require 'indexer_helper/rts/dealer_com_rts'
# # require 'indexer_helper/rts/dealer_direct_rts'
# # require 'indexer_helper/rts/dealer_eprocess_rts'
# # require 'indexer_helper/rts/dealercar_search_rts'
# # # require 'indexer_helper/page_finder_original'  # ### CAN REMOVE THIS.  HAS BEEN REPLACED.
# # require 'indexer_helper/rts/rts_helper'
# # require 'indexer_helper/rts/rts_manager'
# # require 'indexer_helper/unknown_template' # Unknown template's info scraper
# # require 'indexer_helper/helper' # All helper methods for indexer_service
# # require 'servicers/url_verifier' # Bridges UrlRedirector Module to indexer/services.
# # require 'curb' #=> for url_redirector
# ##################################################
#
# require 'complex_query_iterator'
# # require 'net_verifier'
# require 'noko'
#
# #CALL: PageFinder.new.start_page_finder
# class PageFinder
#   include ComplexQueryIterator
#   # include NetVerifier
#   include Noko
#
#   def initialize
#     ## Below are Settings for ComplexQueryIterator Module.
#     @query_count = nil
#     @class_pid = Process.pid
#     @dj_count_limit = 20 #=> Num allowed before releasing next batch.
#     @workers = 3 #=> Divide format_query_results into groups of x.
#     # @timeout = 5 #=> How often to check dj queue count.
#     @timeout = 5
#     @timeout = @timeout
#     @timeout_web_sts = 'timeout1'
#   end
#
#   def start_page_finder
#     query = Web.where(temp_sts: 'valid').order("updated_at ASC").pluck(:id)
#
#     obj_in_grp = 150
#     @query_count = query.count
#     (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2
#
#     # iterate_query(query) # via ComplexQueryIterator
#     query.each { |id| template_starter(id) }
#   end
#
#
#   def template_starter(id)
#     @web_obj = Web.find(id)
#     @url = @web_obj.url
#     noko_hsh = start_noko(@url)
#     page = noko_hsh[:noko_page]
#     err_msg = noko_hsh[:err_msg]
#
#
#     if page.present?
#       parse_page(page, "staff")
#
#       binding.pry
#       parse_page(page, "location")
#       binding.pry
#
#     elsif err_msg.present?
#       puts err_msg
#       binding.pry
#
#       @web_obj.update_attributes(staff_link_sts: err_msg, loc_link_sts: err_msg, staff_text_sts: err_msg, loc_text_sts: err_msg, link_text_date: Time.now)
#     end
#
#   end
#
#   ################################################
#
#   def parse_page(page, mode)
#     list = text_href_list(mode)
#     text_list = list[:text_list]
#
#     for text in text_list
#       links = page.links.select {|link| link.text.downcase.include?(text.downcase)}
#       binding.pry
#
#       if links.any?
#         # url_split_joiner(links.first, mode)
#         break
#       end
#     end
#
#     binding.pry
#     # if links.empty? || links.nil?
#     if !links.present?
#       binding.pry
#       href_list = list[:href_list]
#       href_list.delete(/MeetOurDepartments/) # /MeetOurDepartments/ is the last href to search.
#       for href in href_list
#         if links = page.link_with(:href => href)
#           # url_split_joiner(links, mode)
#           break
#         end
#       end
#       if !links
#         # if links = page.link_with(:href => /MeetOurDepartments/)
#         #     url_split_joiner(links, mode)
#         update_db("PF None", "PF None", nil, nil, mode)
#         # end
#       end
#     end
#
#     # update_db("PF Result", links.text.strip, links.href, joined_url, mode)
#   end
#
#   # def url_split_joiner(links, mode)
#   #   url_s = @url.split('/')
#   #   url_http = url_s[0]
#   #   url_www = url_s[2]
#   #   joined_url = validater(url_http, '//', url_www, links.href)
#   #
#   #   update_db("PF Result", links.text.strip, links.href, joined_url, mode)
#   # end
#
#   def update_db(status, text, href, link, mode)
#     binding.pry
#     # Clean the Data before updating database
#     clean = record_cleaner(text, href, link)
#     text, href, link = clean[:text], clean[:href], clean[:link]
#
#     if mode == "location"
#       # @indexer.update_attributes(indexer_status: "PageFinder", loc_status: status, location_url: link, location_text: text, page_finder_date: DateTime.now) if @indexer != nil
#     elsif mode == "staff"
#       # @indexer.update_attributes(indexer_status: "PageFinder", stf_status: status, staff_url: link, staff_text: text, page_finder_date: DateTime.now) if @indexer != nil
#     end
#   end
#
#   def validater(url_http, dbl_slash, url_www, dirty_url)
#     dirty_url = "/" + dirty_url if dirty_url[0] != "/"
#     dirty_url.include?(url_http + dbl_slash) ? dirty_url : url_http + dbl_slash + url_www + dirty_url
#   end
#
#   def to_regexp(arr)
#     arr.map {|str| Regexp.new(str)}
#   end
#
#   def text_href_list(mode)
#     if mode == "staff"
#       text = "staff_text"
#       href = "staff_href"
#       term = @web_obj.templates&.order("updated_at DESC")&.first&.template_name
#       # special_templates = ["Cobalt", "Dealer Inspire", "DealerFire"]
#       # term = 'general' if !special_templates.include?(term)
#     elsif mode == "location"
#       text = "loc_text"
#       href = "loc_href"
#       term = "general"
#     end
#
#     text_list = Term.where(sub_category: text).where(criteria_term: term).map(&:response_term)
#     href_list = to_regexp(Term.where(sub_category: href).where(criteria_term: term).map(&:response_term))
#     return {text_list: text_list, href_list: href_list}
#     # list = text_href_list(mode)
#     # text_list = list[:text_list]
#   end
#
#
#   def record_cleaner(text, href, link)
#     link = link_deslasher(link)
#     {text: text, href: href, link: link}
#   end
#
#   def link_deslasher(link)
#     link = (link && link[0] == "/") ? link[1..-1] : link
#     link = (link && link[-1] == "/") ? link[0...-1] : link
#   end
#
# end
