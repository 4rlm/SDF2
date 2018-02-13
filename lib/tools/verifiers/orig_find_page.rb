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
    @cut_off = 3.hour.ago
    @make_urlx = FALSE
    @formatter = Formatter.new
    @mig = Mig.new
    @tally_staff_links = Link.order("count DESC").pluck(:staff_link)
    @tally_staff_texts = Text.order("count DESC").pluck(:staff_text)
  end


  def get_query


    ## Invalid Sts Query ##
    query = Act.select(:id).where(page_sts: "Invalid").where('page_date < ? OR page_date IS NULL', @cut_off).order("page_date ASC").pluck(:id)
    # query = Act.where(url: "https://www.newcarlislechryslerjeepdodge.com").pluck(:id)

    print_query_stats(query)
    puts query.count
    sleep(1)
    return query

    ###### SPECIAL ABOVE #######
    ############################

    ## Nil Sts Query ##
    query = Act.select(:id).where(url_sts: 'Valid', temp_sts: 'Valid', page_sts: nil).order("id ASC").pluck(:id)

    ## Valid Sts Query ##
    val_sts_arr = ['Valid']
    query = Act.select(:id).where(url_sts: 'Valid', temp_sts: 'Valid', page_sts: val_sts_arr).where('page_date < ? OR page_date IS NULL', @cut_off).order("id ASC").pluck(:id) if !query.any?

    # ## Invalid Sts Query ##
    # query = Act.select(:id).where(page_sts: "Invalid").where('page_date < ? OR page_date IS NULL', @cut_off).order("id ASC").pluck(:id) if !query.any?

    ## Error Sts Query ##
    if !query.any?
      err_sts_arr = ['Error: Host', 'Error: Timeout', 'Error: TCP']
      query = Act.select(:id).where(url_sts: 'Valid', temp_sts: 'Valid', page_sts: err_sts_arr).order("id ASC").pluck(:id)
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
    puts query.count
    sleep(1)
    return query
  end

  ### CAUTION!  HIDDEN METHOD BELOW!
  def print_query_stats(query)
    puts "\n\n===================="
    puts "@timeout: #{@timeout}\n\n"
    puts "\n\nQuery Count: #{query.count}"
  end

  ### CAUTION!  HIDDEN METHOD BELOW!
  def start_find_page
    query = get_query
    while query.any?
      setup_iterator(query)
      query = get_query
      break if !query.any?
    end
  end

  ### CAUTION!  HIDDEN METHOD BELOW!
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
        act_obj.update(page_sts: err_msg, page_date: Time.now)
      elsif noko_page.present?
        parsed_hsh = parse_page(noko_page, url, act_obj.temp_name)

        staff_link = parsed_hsh[:staff_link]
        staff_link = '/meetourdepartments' if staff_link&.include?('card')
        staff_text = parsed_hsh[:staff_text]

        if !parsed_hsh.values.compact.empty?
          puts "\n\n\n\n==================\n\n"
          puts url
          puts parsed_hsh.inspect
          puts "\n\n==================\n\n\n\n"
        end

        staff_link.present? ? page_sts = 'Valid' : page_sts = 'Invalid'
        act_obj.update(staff_link: staff_link, staff_text: staff_text, page_sts: page_sts, page_date: Time.now)
      end
    end
  end


  ### CAUTION!  HIDDEN METHOD BELOW!
  #CALL: FindPage.new.start_find_page
  def parse_page(noko_page, url, temp_name)
    stock_hsh = get_stocks(temp_name)
    stock_texts = stock_hsh[:stock_texts]
    stock_texts += @tally_staff_texts
    stock_texts.uniq!
    parsed_hsh = {}


    stock_texts.each do |stock_text|
      stock_text = stock_text.downcase&.gsub(/\W/,'')

      if stock_text.present?
        noko_page.links.each do |noko_text_link|
          noko_text = noko_text_link.text&.downcase&.gsub(/\W/,'')

          if noko_text && noko_text&.length > 3
            if noko_text.include?(stock_text) || stock_text.include?(noko_text)
              noko_link = noko_text_link&.href&.downcase&.strip
              noko_link = @formatter.format_link(url, noko_link)

              if is_banned(noko_link, noko_text) != true
                parsed_hsh[:staff_text] = noko_text
                parsed_hsh[:staff_link] = noko_link
                # puts "\n\n======================"
                # puts "url: #{url}"
                # puts parsed_hsh.inspect
                # puts "-------------\n\n"
                return parsed_hsh
              end

            end
          end
        end
      end
    end


    if parsed_hsh.values.compact.empty?
      stock_links = stock_hsh[:stock_links]
      stock_links += @tally_staff_links
      stock_links.uniq!
      stock_links = format_href_list(stock_links)

      stock_links.each do |stock_link|
        stock_link = stock_link.downcase&.strip

         noko_page.links.each do |noko_text_link|
          noko_link = noko_text_link&.href&.downcase&.strip
          noko_link = @formatter.format_link(url, noko_link)

          if noko_link && noko_link&.length > 3
            if noko_link.include?(stock_link) || stock_link.include?(noko_link)
              noko_text = noko_text_link.text&.downcase&.gsub(/\W/,'')

              if is_banned(noko_link, noko_text) != true
                parsed_hsh[:staff_text] = noko_text
                parsed_hsh[:staff_link] = noko_link
                # puts "\n\n======================"
                # puts "url: #{url}"
                # puts parsed_hsh.inspect
                # puts "-------------\n\n"
                return parsed_hsh
              end

            end
          end
        end
      end
    end

    ### Find Links or Texts that include 'sales' or 'team'
    ### VERY INCOMPLETE - NEED TO REFACTOR ABOVE FIRST.
    # if parsed_hsh.values.compact.empty?
    #    noko_page.links.each do |noko_text_link|
    #     noko_link = noko_text_link&.href&.downcase&.strip
    #     noko_link = @formatter.format_link(url, noko_link)
    #
    #     if noko_link && noko_link&.length > 3
    #       noko_text = noko_text_link.text&.downcase&.gsub(/\W/,'')
    #       if is_banned(noko_link, noko_text) != true
    #         parsed_hsh[:staff_text] = noko_text
    #         parsed_hsh[:staff_link] = noko_link
    #         # puts "\n\n======================"
    #         # puts "url: #{url}"
    #         # puts parsed_hsh.inspect
    #         # puts "-------------\n\n"
    #         return parsed_hsh
    #       end
    #     end
    #   end
    # end

    return parsed_hsh
  end



  #CALL: FindPage.new.start_find_page
  def is_banned(staff_link, staff_text)
    return true if !staff_link.present? || !staff_text.present? || staff_link.length < 4
    strict_ban = %w(/about /about-us /about-us.htm /about.htm /about.html /dealership/about.htm /dealership/department.htm /dealership/news.htm /departments.aspx /index.htm /meetourdepartments /sales.aspx /#tab-sales)

    light_ban = %w(404 appl approve body career center click collision contact customer demo direction discl drive employ espaol finan get google guarantee habla history home hour inventory javascript job join lease legal lube mail map match multilingual offers oil open opportunit parts phone place price quick rating review sales_tab schedule search service special survey tel test text trade value vehicle video virtual websiteby welcome why)

    strict_ban.each { |ban| return true if staff_link == ban }
    light_ban.each { |ban| return true if staff_link.include?(ban) || staff_text.include?(ban) }
  end



  ############ HELPER METHODS BELOW ################

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
