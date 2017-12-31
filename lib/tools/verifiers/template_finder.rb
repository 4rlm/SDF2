# Call: TemplateFinder.new.start_template_finder

require 'complex_query_iterator'
require 'url_redirector'
require 'noko'

class TemplateFinder
  include ComplexQueryIterator
  include InternetConnectionValidator
  include Noko

  # Call: TemplateFinder.new.start_template_finder
  def start_template_finder

    ## Below are Settings for ComplexQueryIterator Module.
    @query_count = nil
    @class_pid = Process.pid
    @dj_count_limit = 20 #=> Num allowed before releasing next batch.
    @stage2_workers = 3 #=> Divide format_query_results into groups of x.
    # @dj_wait_time = 5 #=> How often to check dj queue count.

    # @indexer = Indexer.where(id: id).select(:id, :indexer_sts, :clean_url, :template, :template_date, :template_sts).first
    # query = Web.where.not(archived: TRUE, temp_sts: nil).order("updated_at ASC").pluck(:id)
    # query = Web.where.not(archived: TRUE).order("updated_at ASC").pluck(:id)
    query = Web.where(web_sts: '++').order("updated_at ASC").pluck(:id)

    @query_count = query.count
    (@query_count & @query_count > 100) ? @stage1_groups = (@query_count / 100) : @stage1_groups = 2
    @timeout = 5
    @dj_wait_time = @timeout
    @round = 1
    @timeout_web_sts = 'timeout1'

    ## TEMPORARILY BYPASSING iterate_query B/C IT'S DOING BIG JOB NOW ##
    # iterate_query(query) # via ComplexQueryIterator
    query.each { |id| template_starter(id) }
  end

  #############################################
  ## ComplexQueryIterator takes query and creates series of forked iterations based on limits established above in initialize method.  Then it calls 'template_starter(id)' method.  Module serves as bridge for iteration work.
  #############################################


  def template_starter(id)
    @web_obj = Web.find(id)
    @url = @web_obj.url
    # @current_temp = @web_obj.templates&.first&.template_name
    start_noko(@url) ## Returns @html = @agent.get(url_string) from Noko
    html = @html

    terms = Term.where(category: "template_finder").where(sub_category: "at_css")
    terms.map { |term| @new_temp = term.response_term if html.at_css('html').text.include?(term.criteria_term) }

    @new_temp.present? ? @temp_sts = '++' : @temp_sts = '??'
    @temp_sts = @error_code if @error_code.present?

    update_db(id)
  end


  def update_db(id)
    temp_obj = Template.find_by(template_name: @new_temp) if @new_temp.present?
    Migrator.new.create_obj_parent_assoc('template', temp_obj, @web_obj) if temp_obj.present?
    @web_obj.update_attributes(temp_sts: @temp_sts, temp_date: Time.now, updated_at: Time.now)
    tf_starter if id == @last_id
  end


end
