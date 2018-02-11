#CALL: FindPage.new.start_find_page
######### Delayed Job #########
# $ rake jobs:clear

require 'iter_query'
require 'noko'

class FindPage
  include IterQuery
  include Noko

  def initialize
    @dj_on = false
    @dj_count_limit = 5
    @workers = 4
    @obj_in_grp = 40
    @timeout = 10
    @count = 0
    @cut_off = 3.hours.ago
    @make_urlx = FALSE
    @formatter = Formatter.new
    @mig = Mig.new
  end

  def get_query
    ## Nil Sts Query ##
    query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: nil).order("updated_at ASC").pluck(:id)

    ## Valid Sts Query ##
    val_sts_arr = ['Valid']
    query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: val_sts_arr).where('page_date < ? OR page_date IS NULL', @cut_off).order("updated_at ASC").pluck(:id) if !query.any?

    ## Error Sts Query ##
    if !query.any?
      err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
      query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: err_sts_arr).order("updated_at ASC").pluck(:id)
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

  def start_find_page
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
    act_obj = Act.find(id)

    if act_obj.present?
      noko_hsh = start_noko(act_obj.url)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]

      if err_msg.present?
        act_obj.update(page_sts: err_msg, page_date: Time.now)
      elsif noko_page.present?
        staff_hsh = parse_page(act_obj, noko_page, "staff")
        loc_hsh = parse_page(act_obj, noko_page, "location")
        staff_link = staff_hsh[:link]

        staff_link.present? ? page_sts = 'Valid' : page_sts = 'Invalid'
        act_obj.update(staff_link: staff_link, loc_link: loc_hsh[:link], page_sts: page_sts, page_date: Time.now)
        puts act_obj
      end
    end
  end

  def parse_page(act_obj, noko_page, mode)
    list = text_href_list(act_obj, mode)
    text_list = list[:text_list]
    parsed_hsh = {}

    text_list.each do |text|
      text = format_href(text)
      noko_page.links.each do |noko_link|
        link_text = format_href(noko_link&.text)
        if link_text&.include?(text)
          formatted_link = @formatter.format_link(act_obj.url, noko_link&.href)
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
            formatted_link = @formatter.format_link(act_obj.url, noko_link&.href)
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

  ############ HELPER METHODS BELOW ################

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

  def text_href_list(act_obj, mode)
    if mode == "staff"
      text = "staff_text"
      href = "staff_href"
      term = act_obj.temp_name
      special_templates = ["Cobalt", "Dealer Inspire", "DealerFire"]
      term = 'general' if !special_templates.include?(term)
    elsif mode == "location"
      text = "loc_text"
      href = "loc_href"
      term = "general"
    end

    text_list = Term.where(sub_category: text).where(criteria_term: term).map(&:response_term)
    href_list = format_href_list(Term.where(sub_category: href).where(criteria_term: term).map(&:response_term))
    return {text_list: text_list, href_list: href_list}
  end



end
