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
    @dj_count_limit = 30
    @workers = 4
    @obj_in_grp = 50
    @timeout = 10
    @count = 0
    @cut_off = 48.hours.ago
    @prior_query_count = 0

    @mig = Mig.new
    @formatter = Formatter.new
  end


  def get_query
    @count += 1
    @timeout *= @count
    puts "\n\n===================="
    # delete_fwd_web_dups ## Removes duplicates
    puts "@count: #{@count}"
    puts "@timeout: #{@timeout}\n\n"

    # query = Web.where(tmp_sts: 'Valid').order("updated_at ASC").pluck(:id)
    val_sts_arr = ['Valid', nil]
    val_query = Web.select(:id).
      where(url_ver_sts: 'Valid', tmp_sts: 'Valid', slink_sts: val_sts_arr).
      where('slink_sts < ? OR slink_sts IS NULL', @cut_off).
      order("updated_at ASC").
      pluck(:id)

    err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
    err_query = Web.select(:id).
      where(url_ver_sts: 'Valid', tmp_sts: 'Valid', slink_sts: err_sts_arr).
      order("updated_at ASC").
      pluck(:id)

    query = (val_query + err_query)&.uniq
    puts "\n\nQ1-Count: #{query.count}"
    return query
  end

  def start_find_page
    query = get_query
    query_count = query.count
    while query_count != @prior_query_count
      setup_iterator(query)
      @prior_query_count = query_count
      break if (query_count == get_query.count) || @count > 4
      start_find_page
    end
  end

  def setup_iterator(query)
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
    @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }
  end

  def template_starter(id)
    web_obj = Web.find(id)

    if web_obj.present?
      noko_hsh = start_noko(web_obj.url)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]
      web_update_hsh = { pge_date: Time.now }

      if err_msg.present?
        puts err_msg
        web_update_hsh.merge!({slink_sts: err_msg, llink_sts: err_msg, stext_sts: err_msg, ltext_sts: err_msg})
        web_obj.update(web_update_hsh)
      elsif noko_page.present?
        staff_hsh = parse_page(web_obj, noko_page, "staff")
        staff_link = staff_hsh[:link]
        staff_text = staff_hsh[:text]
        staff_link.present? ? slink_sts = 'Valid' : slink_sts = 'Invalid'
        staff_link_hsh = {link: staff_link, link_type: 'staff', link_sts: slink_sts}
        staff_text.present? ? stext_sts = 'Valid' : stext_sts = 'Invalid'
        staff_text_hsh = {text: staff_text, text_type: 'staff', text_sts: stext_sts}

        loc_hsh = parse_page(web_obj, noko_page, "location")
        loc_link = loc_hsh[:link]
        loc_text = loc_hsh[:text]
        loc_link.present? ? llink_sts = 'Valid' : llink_sts = 'Invalid'
        loc_link_hsh = {link: loc_link, link_type: 'loc', link_sts: llink_sts}
        loc_text.present? ? ltext_sts = 'Valid' : ltext_sts = 'Invalid'
        loc_text_hsh = {text: loc_text, text_type: 'loc', text_sts: ltext_sts}

        web_update_hsh.merge!({slink_sts: slink_sts, llink_sts: llink_sts, stext_sts: stext_sts, ltext_sts: ltext_sts})
        web_obj.update(web_update_hsh)

        update_db(id, web_obj, staff_link_hsh, loc_link_hsh, staff_text_hsh, loc_text_hsh) if slink_sts == 'Valid' || llink_sts == 'Valid' || stext_sts == 'Valid' || ltext_sts == 'Valid'
      end
    end
  end


  def update_db(id, web_obj, staff_link_hsh, loc_link_hsh, staff_text_hsh, loc_text_hsh)
    staff_link = staff_link_hsh[:link]
    staff_link_obj = @mig.save_comp_obj('link', {'link' => staff_link}, staff_link_hsh) if staff_link.present?
    @mig.create_obj_parent_assoc('link', staff_link_obj, web_obj) if staff_link_obj.present?

    loc_link = loc_link_hsh[:link]
    loc_link_obj = @mig.save_comp_obj('link', {'link' => loc_link}, loc_link_hsh) if loc_link.present?
    @mig.create_obj_parent_assoc('link', loc_link_obj, web_obj) if loc_link_obj.present?

    staff_text = staff_text_hsh[:text]
    staff_text_obj = @mig.save_comp_obj('text', {'text' => staff_text}, staff_text_hsh) if staff_text.present?
    @mig.create_obj_parent_assoc('text', staff_text_obj, web_obj) if staff_text_obj.present?

    loc_text = loc_text_hsh[:text]
    loc_text_obj = @mig.save_comp_obj('text', {'text' => loc_text}, loc_text_hsh) if loc_text.present?
    @mig.create_obj_parent_assoc('text', loc_text_obj, web_obj) if loc_text_obj.present?

    print_page_results(staff_link_hsh, loc_link_hsh, staff_text_hsh, loc_text_hsh)
    binding.pry
  end


  def print_page_results(staff_link_hsh, loc_link_hsh, staff_text_hsh, loc_text_hsh)
    puts "\n\n================"
    puts staff_link_hsh.to_yaml
    puts loc_link_hsh.to_yaml
    puts staff_text_hsh.to_yaml
    puts loc_text_hsh.to_yaml
    puts "==================\n\n\n"
    # tf_starter if id == @last_id
  end


  def parse_page(web_obj, noko_page, mode)
    list = text_href_list(web_obj, mode)
    text_list = list[:text_list]
    parsed_hsh = {}

    text_list.each do |text|
      text = format_href(text)
      noko_page.links.each do |noko_link|
        link_text = format_href(noko_link&.text)
        if link_text&.include?(text)
          formatted_link = @formatter.format_link(web_obj.url, noko_link&.href)
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
            formatted_link = @formatter.format_link(web_obj.url, noko_link&.href)
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
      term = web_obj.temp_name
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
