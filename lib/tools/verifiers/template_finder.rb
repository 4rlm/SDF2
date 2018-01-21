# Call: TemplateFinder.new.start_template_finder

require 'complex_query_iterator'
require 'curler'
require 'noko'

class TemplateFinder
  include ComplexQueryIterator
  include Noko

  def initialize
    @migrator = Migrator.new
    ### for ComplexQueryIterator ###
    @timeout = 5
    @dj_count_limit = 30 #=> Num allowed before releasing next batch.
    @workers = 4 #=> Divide format_query_results into groups of x.
    ### for UrlVerifier ###
    @obj_in_grp = 50
    # @cut_off = 6.hours.ago  ## Not implemented yet.

    ## Breaks while looping if number doesn't change after each round.
    # @prior_host_q_count = 0 ## Not implemented yet.
    # @prior_timeout_q_count = 0 ## Not implemented yet.
  end

  ################################
  def get_primary_query
    # sts_codes = Web.where(sts_code: [200..299]).count
    primary_query = Web.where(url_ver_sts: 'valid', tmp_sts: nil).order("updated_at ASC").pluck(:id)
  end

  def get_tcp_query
    tcp_query = Web.where(tmp_sts: 'Error: TCP').order("updated_at ASC").pluck(:id)
  end

  def get_timeout_query
    timeout_query = Web.where("tmp_sts LIKE '%timeout%'").order("updated_at ASC").pluck(:id)
  end
  ################################

  # Call: TemplateFinder.new.start_template_finder
  def start_template_finder
    primary_query = get_primary_query
    primary_query_count = primary_query.count
    while primary_query_count > 0
      setup_iterator(primary_query)
      break if primary_query_count == get_primary_query.count
      start_template_finder
    end

    timeout_query = get_timeout_query
    timeout_query_count = timeout_query.count
    @timeout = 30
    if timeout_query_count > 0
      setup_iterator(timeout_query)
      # break if timeout_query_count == get_timeout_query.count
      # start_template_finder
    end

    tcp_query = get_tcp_query
    tcp_query_count = tcp_query.count
    if tcp_query_count > 0
      setup_iterator(tcp_query)
      # break if tcp_query_count == get_tcp_query.count
      # start_template_finder
    end

  end


  def setup_iterator(query)
    ## Assigned to instance variables, so they can display results before each batch runs.
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2

    iterate_query(query) # via ComplexQueryIterator
    # query.each { |id| template_starter(id) }
  end


  def template_starter(id)
    web_obj = Web.find(id)
    url = web_obj.url
    noko_hsh = start_noko(url)
    page = noko_hsh[:noko_page]
    err_msg = noko_hsh[:err_msg]

    if page.present?
      new_temp = Term.where(category: "template_finder").where(sub_category: "at_css").select { |term| term.response_term if page&.at_css('html')&.text&.include?(term.criteria_term) }&.first&.response_term
      new_temp.present? ? tmp_sts = 'valid' : tmp_sts = 'unidentified'
      cur_temp = web_obj.templates&.order("updated_at DESC")&.first&.temp_name
    end

    if err_msg.present?
      tmp_sts = err_msg
      new_temp = 'search error'
    end

    puts "\n\n================"
    puts "cur_temp: #{cur_temp}"
    puts "new_temp: #{new_temp}"
    puts "tmp_sts: #{tmp_sts}\n\n"

    update_db(id, web_obj, new_temp, tmp_sts)
  end


  def update_db(id, web_obj, new_temp, tmp_sts)
    temp_obj = Template.find_by(temp_name: new_temp) if new_temp.present?
    @migrator.create_obj_parent_assoc('template', temp_obj, web_obj) if temp_obj.present?
    web_obj.update_attributes(tmp_sts: tmp_sts, tmp_date: Time.now, updated_at: Time.now)
    # tf_starter if id == @last_id
  end


end
