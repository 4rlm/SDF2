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
    @timeout = 10
    @count = 0
    @cut_off = 7.hours.ago
    @make_urlx = FALSE
    @formatter = Formatter.new
    @mig = Mig.new
    @tally_staff_links = Link.order("count DESC").pluck(:staff_link)
    @tally_staff_texts = Text.order("count DESC").pluck(:staff_text)
    @banned = %w(value trade finan collision job open click video legal discl schedule test drive virtual tour offers appl body employ opportunit career inventory service hour direction map search vehicle contact habla espaol get pre approve why lease demo special home quick lube center oil part price match guarantee text phone tel mail welcome history javascript 404 join survey customer review rating google place)
  end


  def get_query
    # Reporter.tally_links
    # Reporter.tally_texts
    # sleep(5)
    # @tally_staff_links = Link.order("count DESC").pluck(:staff_link)
    # @tally_staff_texts = Text.order("count DESC").pluck(:staff_text)

    ## Nil Sts Query ##
    query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: nil).order("updated_at ASC").pluck(:id)

    ## Valid Sts Query ##
    val_sts_arr = ['Valid']
    query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: val_sts_arr).where('page_date < ? OR page_date IS NULL', @cut_off).order("updated_at ASC").pluck(:id) if !query.any?

    ## Invalid Sts Query ##
    query = Act.select(:id).where(urlx: FALSE, url_sts: 'Valid', temp_sts: 'Valid', page_sts: "Invalid").where('page_date < ? OR page_date IS NULL', @cut_off).order("updated_at ASC").pluck(:id) if !query.any?

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
    url = act_obj.url

    if act_obj.present?
      noko_hsh = start_noko(url)
      noko_page = noko_hsh[:noko_page]
      err_msg = noko_hsh[:err_msg]

      if err_msg.present?
        act_obj.update(page_sts: err_msg, page_date: Time.now)
      elsif noko_page.present?
        parsed_hsh = parse_page(noko_page, url)

        if !parsed_hsh.values.compact.empty?
          staff_text = parsed_hsh[:staff_text]
          staff_link = parsed_hsh[:staff_link]
          staff_link = '/meetourdepartments' if staff_link&.include?('card')
          puts staff_link
          puts staff_text

          act_obj.update(staff_link: staff_link, staff_text: staff_text, page_sts: 'Valid', page_date: Time.now)
        else
          act_obj.update(staff_link: nil, staff_text: nil, page_sts: 'Invalid', page_date: Time.now)
        end

        puts act_obj
      end
    end
  end





  #CALL: FindPage.new.start_find_page
  def parse_page(noko_page, url)
    if noko_page.present?
      parsed_hsh = {}
      noko_page.links.each do |noko_link|
        # staff_link = noko_link&.href&.downcase&.strip
        staff_link = @formatter.format_link(url, noko_link&.href)
        staff_text = noko_link.text&.downcase&.gsub!(/\W/,'')

        if is_banned(staff_link, staff_text) != true

          if parsed_hsh.values.compact.empty?
            @tally_staff_links.each do |tally_staff_link|
              if tally_staff_link.downcase == staff_link
                parsed_hsh[:staff_link] = staff_link
                parsed_hsh[:staff_text] = staff_text
                puts parsed_hsh
                return parsed_hsh
              end
            end
          end

          if parsed_hsh.values.compact.empty?
            @tally_staff_texts.each do |tally_staff_text|
              if tally_staff_text == staff_text
                parsed_hsh[:staff_link] = staff_link
                parsed_hsh[:staff_text] = staff_text
                puts parsed_hsh
                return parsed_hsh
              end
            end
          end

        end
      end

      return parsed_hsh
    end
  end

  #CALL: FindPage.new.start_find_page
  def is_banned(staff_link, staff_text)
    if staff_link.present? && staff_text.present?
      @banned.each do |ban|
        return true if staff_link.include?(ban) || staff_text.include?(ban)
      end

      miniban = %w(# /)
      miniban.each { |ban| return true if staff_link == ban }
    else
      return true
    end
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


end
