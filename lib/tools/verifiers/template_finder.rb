# Call: TemplateFinder.new.start_template_finder

require 'complex_query_iterator'
require 'curler'
require 'noko'

class TemplateFinder
  include ComplexQueryIterator
  include Noko

  def initialize
    @timeout = 10
    @dj_count_limit = 25 #=> Num allowed before releasing next batch.
    @workers = 4 #=> Divide format_query_results into groups of x.
  end


  def get_primary_query
    # query = Web.where(web_sts: 'valid').order("updated_at ASC").pluck(:id)
    # sts_codes = Web.where(sts_code: [200..299]).count
    # primary_query = Web.where(web_sts: 'valid', sts_code: 200, temp_sts: nil).order("updated_at ASC").pluck(:id)
    # primary_query = Web.where(web_sts: 'valid', sts_code: 200, temp_sts: 'valid').order("updated_at ASC").pluck(:id)
    primary_query = Web.where(web_sts: 'valid', temp_sts: nil).order("updated_at ASC").pluck(:id)
  end


  def get_tcp_query
    # tcp_query = Web.where(web_sts: 'valid', sts_code: 200).where("temp_sts LIKE '%Error%'").order("updated_at ASC").pluck(:id)
    # tcp_query = Web.where("temp_sts LIKE '%Error%'").order("updated_at ASC").pluck(:id)
    # tcp_query = Web.where(web_sts: 'valid', sts_code: 200, temp_sts: 'Error: TCP').order("updated_at ASC").pluck(:id)
    tcp_query = Web.where(temp_sts: 'Error: TCP').order("updated_at ASC").pluck(:id)
  end


  # Call: TemplateFinder.new.start_template_finder
  def start_template_finder

    primary_query = get_primary_query
    primary_query_count = primary_query.count
    while primary_query_count > 0
      setup_iterator(primary_query)
      break if primary_query_count == get_primary_query.count
      start_template_finder
    end

    tcp_query = get_tcp_query
    tcp_query_count = tcp_query.count
    while tcp_query_count > 0
      setup_iterator(tcp_query)
      break if tcp_query_count == get_tcp_query.count
      start_template_finder
    end

  end


  def setup_iterator(query)
    obj_in_grp = 30
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

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
      new_temp.present? ? temp_sts = 'valid' : temp_sts = 'unidentified'
      cur_temp = web_obj.templates&.order("updated_at DESC")&.first&.template_name
    end

    if err_msg.present?
      temp_sts = err_msg
      new_temp = 'search error'
    end

    puts "\n\n================"
    puts "cur_temp: #{cur_temp}"
    puts "new_temp: #{new_temp}"
    puts "temp_sts: #{temp_sts}\n\n"

    update_db(id, web_obj, new_temp, temp_sts)
  end


  def update_db(id, web_obj, new_temp, temp_sts)
    temp_obj = Template.find_by(template_name: new_temp) if new_temp.present?
    Migrator.new.create_obj_parent_assoc('template', temp_obj, web_obj) if temp_obj.present?
    web_obj.update_attributes(temp_sts: temp_sts, temp_date: Time.now, updated_at: Time.now)
    # tf_starter if id == @last_id
  end


end
