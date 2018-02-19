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
    @timeout = 5
    @count = 0
    @cut_off = 5.hour.ago
    @make_urlx = FALSE
    @formatter = Formatter.new
    @mig = Mig.new
    @tally_staff_links = Link.order("count DESC").pluck(:staff_link)
    @tally_staff_texts = Text.order("count DESC").pluck(:staff_text)
  end


  def get_query
    ### TESTING QUERIES BELOW - WILL DELETE AFTER REFACTORING SCHEMA AND PROCESS FOR FindPage, Link, ActLink, Tally.

    query = Act.select(:id).where(page_sts: 'Valid')
      .where('page_date < ? OR page_date IS NULL', @cut_off)
      .order("id ASC").pluck(:id)

    print_query_stats(query)
    sleep(2)
    # binding.pry
    return query


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
      # @cut_off = 15.hour.ago
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

  #CALL: FindPage.new.start_find_page
  def template_starter(id)
    act_obj = Act.find(id)
    url = act_obj.url

    if act_obj.present?
      noko_hsh = start_noko(url)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]

      if err_msg.present?
        binding.pry
        act_obj.update(page_sts: err_msg, page_date: Time.now)
      elsif noko_page.present?
        # parsed_hsh = parse_page(noko_page, act_obj)
        link_text_results = parse_page(noko_page, act_obj)

        if !link_text_results.any?
          binding.pry
          act_obj.update(page_sts: 'Invalid', page_date: Time.now)
        else
          link_text_results.each do |link_text_hsh|
            puts link_text_hsh
            binding.pry
            link_obj = Link.find_or_create_by(link_text_hsh)
            act_obj.link << link_obj
            act_obj.update(page_sts: 'Valid', page_date: Time.now)
          end
        end

        ### REFACTORING - BELOW NEEDS TO BE REFACTORED.  RETURN link_text_results TO GO TO db_update method WHERE ARRAY OF HASHES WILL FIND OR CREATE NEW LINK OBJ THEN ASSOCIATED WITH ACT_OBJ.

        ### ORIGINAL BELOW.  WILL BE REFACTORED ABOVE ###
        # staff_link = parsed_hsh[:staff_link]
        # # staff_link = '/meetourdepartments' if staff_link&.include?('card')
        # staff_text = parsed_hsh[:staff_text]
        #
        # if !parsed_hsh.values.compact.empty?
        #   puts "\n\n\n\n==================\n\n"
        #   puts url
        #   puts parsed_hsh.inspect
        #   puts "\n\n==================\n\n\n\n"
        # end
        #
        # staff_link.present? ? page_sts = 'Valid' : page_sts = 'Invalid'
        # act_obj.update(staff_link: staff_link, staff_text: staff_text, page_sts: page_sts, page_date: Time.now)
      end
    end
  end

  #CALL: FindPage.new.start_find_page
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


    ### REFACTORING - IMPORTANT!
    link_text_results = [] ## All results shoveled into here as hashes, then iterate through at final stage to find_or_create then assign link_obj to act_obj.
    noko_page.links.each do |noko_text_link|
      noko_text = noko_text_link.text&.downcase&.gsub(/\W/,'')
      pre_noko_link = noko_text_link&.href&.downcase&.strip
      noko_link = @formatter.format_link(url, pre_noko_link)

      if (noko_text && noko_link) && (noko_text.length > 3 && noko_link.length > 3) && (is_banned(noko_link, noko_text, temp_name) != true)

      #### BEGIN REFACTORING HERE ####
      ## Save all valid Text and Link to join table, rather than only saving one link and one text in Act.  Keep page_sts, page_date in Act, but move staff_link and staff_text to Link (will save both link and text in same table, as is in Act currently.  As for the current Link and Text tables, those will be droped and replaced with Tally table. - be sure back up first!)
      # - Change each return below to shovel into an array of hashes.  After all noko links checked, create method to find_or_create corresponding text and link (pair) in Link table, then shovel each object into the act_obj for joined.
      ##### IMPORTANT ABOVE #######

        ## If No Matching Texts or Links find any that include 'team' or 'staff'
        if noko_text.include?('staff') || noko_link.include?('staff')
          # return {staff_text: noko_text, staff_link: noko_link}

          link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
          link_text_results << link_text_hsh
          puts link_text_hsh.inspect
          binding.pry
        end

        ## Links 2nd Priorty Order: Only Runs if ALL Texts above are nil
        stock_links.each do |stock_link|
          stock_link = stock_link.downcase&.strip
          if noko_link.include?(stock_link) || stock_link.include?(noko_link)
            # return {staff_text: noko_text, staff_link: noko_link}

            link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
            link_text_results << link_text_hsh
            puts link_text_hsh.inspect
            binding.pry
          end
        end

        ## Texts 1st Priorty Order
        stock_texts.each do |stock_text|
          stock_text = stock_text.downcase&.gsub(/\W/,'')
          if noko_text.include?(stock_text) || stock_text.include?(noko_text)
            # return {staff_text: noko_text, staff_link: noko_link}

            link_text_hsh = {staff_text: noko_text, staff_link: noko_link}
            link_text_results << link_text_hsh
            puts link_text_hsh.inspect
            binding.pry
          end
        end

      end
    end

    #CALL: FindPage.new.start_find_page
    puts "\n\n===================="
    puts "RAW RESULTS: #{link_text_results.count}"
    puts link_text_results.inspect

    link_text_results = link_text_results.uniq
    puts "\n\n===================="
    puts "UNIQ RESULTS: #{link_text_results.count}"
    puts link_text_results.inspect
    binding.pry

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

    light_ban = %w(404 appl approve body career center click collision commercial contact customer demo direction discl drive employ espanol espaol finan get google guarantee habla history home hour inventory javascript job join lease legal location lube mail map match multilingual offers oil open opportunit parts phone place price quick rating review sales_tab schedule search service special start yourdeal survey tel test text trade value vehicle video virtual websiteby welcome why)

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
