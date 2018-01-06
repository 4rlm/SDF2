# Call: TemplateFinder.new.start_template_finder

require 'complex_query_iterator'
require 'curler'
# require 'net_verifier'
require 'noko'

class TemplateFinder
  include ComplexQueryIterator
  # include NetVerifier
  include Noko

  def initialize
    ## Below are Settings for ComplexQueryIterator Module.
    @query_count = nil
    @class_pid = Process.pid
    @dj_count_limit = 20 #=> Num allowed before releasing next batch.
    @workers = 3 #=> Divide format_query_results into groups of x.
    # @timeout = 5 #=> How often to check dj queue count.
    @timeout = 5
    @timeout = @timeout
    @timeout_web_sts = 'timeout1'
  end

  # Call: TemplateFinder.new.start_template_finder
  def start_template_finder


    # @indexer = Indexer.where(id: id).select(:id, :indexer_sts, :clean_url, :template, :template_date, :template_sts).first
    # query = Web.where.not(archived: TRUE, temp_sts: nil).order("updated_at ASC").pluck(:id)
    # query = Web.where.not(archived: TRUE).order("updated_at ASC").pluck(:id)
    # query = Web.where(web_sts: 'valid').order("updated_at ASC").pluck(:id)
    query = Web.where(web_sts: 'valid').where(temp_sts: nil).order("updated_at ASC").pluck(:id)

    obj_in_grp = 150
    @query_count = query.count
    (@query_count & @query_count > obj_in_grp) ? @group_count = (@query_count / obj_in_grp) : @group_count = 2

    ## TEMPORARILY BYPASSING iterate_query B/C IT'S DOING BIG JOB NOW ##
    iterate_query(query) # via ComplexQueryIterator
    # query.each { |id| template_starter(id) }
  end


  def template_starter(id)
    @web_obj = Web.find(id)
    @url = @web_obj.url
    noko_hsh = start_noko(@url)
    page = noko_hsh[:noko_page]
    err_msg = noko_hsh[:err_msg]

    if page.present?
      terms = Term.where(category: "template_finder").where(sub_category: "at_css")
      terms.map { |term| @new_temp = term.response_term if page&.at_css('html')&.text&.include?(term.criteria_term) }

      # @new_temp.present? ? @temp_sts = 'valid' : @temp_sts = '??'
      if @new_temp.present?
        # @cur_temp = @web_obj.templates&.last&.template_name
        @cur_temp = @web_obj.templates&.order("updated_at DESC")&.first&.template_name
        @temp_sts = 'valid'
        puts "\n\n================"
        puts "cur_temp: #{@cur_temp}"
        puts "new_temp: #{@new_temp}\n\n"
      end
    elsif err_msg.present?
      @temp_sts = err_msg
      puts @temp_sts
    end

    update_db(id)
  end


  def update_db(id)
    temp_obj = Template.find_by(template_name: @new_temp) if @new_temp.present?
    Migrator.new.create_obj_parent_assoc('template', temp_obj, @web_obj) if temp_obj.present?
    @web_obj.update_attributes(temp_sts: @temp_sts, temp_date: Time.now, updated_at: Time.now)
    tf_starter if id == @last_id
  end


end
