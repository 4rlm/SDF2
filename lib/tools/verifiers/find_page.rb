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
    @obj_in_grp = 50
    @timeout = 15
    @count = 0
    @cut_off = 20.hour.ago
    @make_urlx = FALSE
    @formatter = Formatter.new
    @mig = Mig.new
    # @tally_staff_links = Link.order("count DESC").pluck(:staff_link)
    # @tally_staff_texts = Text.order("count DESC").pluck(:staff_text)
    @tally_staff_links = Dash.where(category: 'staff_link').order("count DESC").pluck(:focus)
    @tally_staff_texts = Dash.where(category: 'staff_text').order("count DESC").pluck(:focus)
  end


  def get_query
    ### TESTING QUERIES BELOW - WILL DELETE AFTER REFACTORING SCHEMA AND PROCESS FOR FindPage, Link, ActLink, Dash.
    # query = Act.select(:id).where(page_sts: 'Valid')
    #   .where('page_date < ? OR page_date IS NULL', @cut_off)
    #   .order("id ASC").pluck(:id)
    #
    # print_query_stats(query)
    # binding.pry
    # return query


    ### REAL QUERIES BELOW - MIGHT NEED TO MODIFY, BUT GENERALLY GOOD.
    # @cut_off = 60.minutes.ago
    ## Invalid Sts Query ##
    query = Act.select(:id).where(page_sts: "Invalid")
      .where('page_date < ? OR page_date IS NULL', @cut_off)
      .order("page_date ASC").pluck(:id)

      ## Nil Sts Query ##
      query = Act.select(:id).where(temp_sts: 'Valid', page_sts: nil)
        .order("id ASC").pluck(:id) if !query.any?

    if !query.any?
      ## Valid Sts Query ##
      query = Act.select(:id).where(page_sts: 'Valid')
        .where('page_date < ? OR page_date IS NULL', @cut_off)
        .order("id ASC").pluck(:id)
    end

    ## Error Sts Query ##
    if !query.any?
      err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
      query = Act.select(:id).where(page_sts: err_sts_arr)
        .order("id ASC").pluck(:id)

      @timeout = 60
      if query.any? && @make_urlx
        query.each { |id| act_obj = Act.find(id).update(page_sts: 'Invalid') }
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
    url = act_obj.url

    if act_obj.present?
      noko_hsh = start_noko(url)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]

      if err_msg.present?
        act_obj.update(page_sts: err_msg, page_date: Time.now)
      elsif noko_page.present?
        link_text_results = parse_page(noko_page, act_obj)
        if !link_text_results.any?
          act_obj.update(page_sts: 'Invalid', page_date: Time.now)
        else
          link_text_results.each do |link_text_hsh|
            link_obj = Link.find_or_create_by(link_text_hsh)
            act_link = act_obj.links.where(id: link_obj).exists?
            act_obj.links << link_obj if !act_link.present?
            act_obj.update(page_sts: 'Valid', page_date: Time.now)
          end
        end
      end
    end
  end


  def parse_page(noko_page, act_obj)
    url = act_obj.url
    temp_name = act_obj.temp_name
    cur_staff_link = act_obj.staff_link
    cur_staff_text = act_obj.staff_text
    cs_sts = act_obj.cs_sts

    stock_hsh = get_stocks(temp_name)
    stock_texts = stock_hsh[:stock_texts]
    stock_texts += @tally_staff_texts
    stock_texts.uniq!

    stock_links = stock_hsh[:stock_links]
    stock_links += @tally_staff_links
    stock_links.uniq!
    stock_links = format_href_list(stock_links)

    ## Note!!!!
    ## REMOVE cur_staff_link AND cur_staff_text from available options if cs_sts = 'Invalid', then add to bottom of list.
    if cs_sts == 'Invalid'
      if stock_texts.include?(cur_staff_text)
        stock_texts.delete(cur_staff_text)
        stock_texts << cur_staff_text ## Should be last in arr.
      end

      if stock_links.include?(cur_staff_link)
        stock_links.delete(cur_staff_link)
        stock_links << cur_staff_link ## Should be last in arr.
      end
    end


    link_text_results = []
    noko_page.links.each do |noko_text_link|
      noko_text = noko_text_link.text&.downcase&.gsub(/\W/,'')
      pre_noko_link = noko_text_link&.href&.downcase&.strip
      noko_link = @formatter.format_link(url, pre_noko_link)

      if (noko_text && noko_link) && (noko_text.length > 3 && noko_link.length > 3) && (is_banned(noko_link, noko_text, temp_name) != true)
        ## If No Matching Texts or Links find any that include 'team' or 'staff'
        if noko_text.include?('staff') || noko_link.include?('staff')
          link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
          link_text_results << link_text_hsh
        end

        ## Links 2nd Priorty Order: Only Runs if ALL Texts above are nil
        stock_links.each do |stock_link|
          stock_link = stock_link.downcase&.strip
          if noko_link.include?(stock_link) || stock_link.include?(noko_link)
            link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
            link_text_results << link_text_hsh
          end
        end

        ## Texts 1st Priorty Order
        stock_texts.each do |stock_text|
          stock_text = stock_text.downcase&.gsub(/\W/,'')
          if noko_text.include?(stock_text) || stock_text.include?(noko_text)
            link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
            link_text_results << link_text_hsh
          end
        end

      end
    end


    link_text_results.uniq!
    puts "\n\n===================="
    puts "UNIQ RESULTS: #{link_text_results.count}"
    puts link_text_results.inspect
    # binding.pry if !link_text_results.any?

    return link_text_results
    # return {} ## Avoids errors if nil.
  end










  ############ HELPER METHODS BELOW ################

  #CALL: FindPage.new.start_find_page
  def is_banned(staff_link, staff_text, temp_name)
    return true if !staff_link.present? || !staff_text.present? || staff_link.length < 4
    link_strict_ban = %w(/about /about-us /about-us.htm /about.htm /about.html /#commercial /commercial.html /dealership/about.htm /dealeronlineretailing_d /dealeronlineretailing /dealership/department.htm /dealership/news.htm /departments.aspx /fleet /index.htm /meetourdepartments /sales.aspx /#tab-sales)

    return true if (temp_name = "Cobalt" && staff_text == 'sales')
    return true if (staff_text == 'porsche')

    # text_strict_ban = %w(sales)
    # text_strict_ban.each { |ban| return true if staff_text == ban }

    light_ban = %w(404 appl approve body career center click collision commercial contact customer demo direction discl drive employ espanol espaol finan get google guarantee habla history home hour inventory javascript job join lease legal location lube mail map match multilingual offers oil open opportunit parts phone place price quick rating review sales_tab schedule search service special start yourdeal survey tel test text trade value vehicle video virtual websiteby welcome why facebook commercial twit)

    link_strict_ban.each { |ban| return true if staff_link == ban }
    light_ban.each { |ban| return true if staff_link.include?(ban) || staff_text.include?(ban) }
  end


  #CALL: FindPage.new.start_find_page
  def format_href_list(arr)
    if arr.include?('/meetourdepartments')
      arr.delete("/meetourdepartments")
      arr << "/meetourdepartments" ## Should be last in arr.
    end

    if arr.include?('/about-us')
      arr.delete("/about-us")
      arr << "/about-us" ## Should be last in arr.
    end

    return arr
  end

  # def format_href(href)
  #   if href.present?
  #     href = href.downcase
  #     href = href.gsub(/[^A-Za-z0-9]/, '')
  #     return href if href.present?
  #   end
  # end

  def get_stocks(temp_name)
    special_templates = ["Cobalt", "Dealer Inspire", "DealerFire"]
    temp_name = 'general' if !special_templates.include?(temp_name)

    stock_texts = Term.where(sub_category: "staff_text").where(criteria_term: temp_name).map(&:response_term)
    stock_links = Term.where(sub_category: "staff_href").where(criteria_term: temp_name).map(&:response_term)
    return {stock_texts: stock_texts, stock_links: stock_links}
  end


end
