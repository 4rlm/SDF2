#CALL: PageFinder.new.start_page_finder
require 'complex_query_iterator'
require 'noko'

class PageFinder
  include ComplexQueryIterator
  include Noko

  def initialize
    @timeout = 10
    @dj_count_limit = 25 #=> Num allowed before releasing next batch.
    @workers = 4 #=> Divide format_query_results into groups of x.
  end

  def start_page_finder
    query = Web.where(temp_sts: 'valid').order("updated_at ASC").pluck(:id)

    obj_in_grp = 30
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

    iterate_query(query) # via ComplexQueryIterator
    # query.each { |id| template_starter(id) }
  end


  def template_starter(id)
    web_obj = Web.find(id)
    noko_hsh = start_noko(web_obj.url)
    noko_page = noko_hsh[:noko_page]
    err_msg = noko_hsh[:err_msg]
    web_update_hsh = { link_text_date: Time.now }

    if err_msg.present?
      puts err_msg
      web_update_hsh.merge!({staff_link_sts: err_msg, loc_link_sts: err_msg, staff_text_sts: err_msg, loc_text_sts: err_msg})
      web_obj.update_attributes(web_update_hsh)
    elsif noko_page.present?
      staff_hsh = parse_page(web_obj, noko_page, "staff")
      staff_link = staff_hsh[:link]
      staff_text = staff_hsh[:text]
      staff_link.present? ? staff_link_sts = 'valid' : staff_link_sts = 'invalid'
      staff_link_hsh = {link: staff_link, link_type: 'staff', link_sts: staff_link_sts}
      staff_text.present? ? staff_text_sts = 'valid' : staff_text_sts = 'invalid'
      staff_text_hsh = {text: staff_text, text_type: 'staff', text_sts: staff_text_sts}

      loc_hsh = parse_page(web_obj, noko_page, "location")
      loc_link = loc_hsh[:link]
      loc_text = loc_hsh[:text]
      loc_link.present? ? loc_link_sts = 'valid' : loc_link_sts = 'invalid'
      loc_link_hsh = {link: loc_link, link_type: 'loc', link_sts: loc_link_sts}
      loc_text.present? ? loc_text_sts = 'valid' : loc_text_sts = 'invalid'
      loc_text_hsh = {text: loc_text, text_type: 'loc', text_sts: loc_text_sts}

      web_update_hsh.merge!({staff_link_sts: staff_link_sts, loc_link_sts: loc_link_sts, staff_text_sts: staff_text_sts, loc_text_sts: loc_text_sts})
      web_obj.update_attributes(web_update_hsh)

      update_db(id, web_obj, staff_link_hsh, loc_link_hsh, staff_text_hsh, loc_text_hsh) if staff_link_sts == 'valid' || loc_link_sts == 'valid' || staff_text_sts == 'valid' || loc_text_sts == 'valid'
    end
  end


  def update_db(id, web_obj, staff_link_hsh, loc_link_hsh, staff_text_hsh, loc_text_hsh)
    staff_link = staff_link_hsh[:link]
    staff_link_obj = Migrator.new.save_complex_obj('link', {'link' => staff_link}, staff_link_hsh) if staff_link.present?
    Migrator.new.create_obj_parent_assoc('link', staff_link_obj, web_obj) if staff_link_obj.present?

    loc_link = loc_link_hsh[:link]
    loc_link_obj = Migrator.new.save_complex_obj('link', {'link' => loc_link}, loc_link_hsh) if loc_link.present?
    Migrator.new.create_obj_parent_assoc('link', loc_link_obj, web_obj) if loc_link_obj.present?

    staff_text = staff_text_hsh[:text]
    staff_text_obj = Migrator.new.save_complex_obj('text', {'text' => staff_text}, staff_text_hsh) if staff_text.present?
    Migrator.new.create_obj_parent_assoc('text', staff_text_obj, web_obj) if staff_text_obj.present?

    loc_text = loc_text_hsh[:text]
    loc_text_obj = Migrator.new.save_complex_obj('text', {'text' => loc_text}, loc_text_hsh) if loc_text.present?
    Migrator.new.create_obj_parent_assoc('text', loc_text_obj, web_obj) if loc_text_obj.present?


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
    href_list = format_href_list(Term.where(sub_category: href).where(criteria_term: term).map(&:response_term))
    return {text_list: text_list, href_list: href_list}
  end



end
