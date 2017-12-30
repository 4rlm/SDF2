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
    @raw_query_count = nil
    @class_pid = Process.pid
    @dj_count_limit = 20 #=> Num allowed before releasing next batch.
    @stage2_workers = 3 #=> Divide format_query_results into groups of x.
    # @dj_wait_time = 5 #=> How often to check dj queue count.

    # @indexer = Indexer.where(id: id).select(:id, :indexer_sts, :clean_url, :template, :template_date, :template_sts).first
    # raw_query = Web.where.not(archived: TRUE, temp_sts: nil).order("updated_at ASC").pluck(:id)
    raw_query = Web.where.not(archived: TRUE).order("updated_at ASC").pluck(:id)

    @raw_query_count = raw_query.count
    (@raw_query_count & @raw_query_count > 100) ? @stage1_groups = (@raw_query_count / 100) : @stage1_groups = 2
    @timeout = 5
    @dj_wait_time = @timeout
    @round = 1
    @timeout_web_sts = 'timeout1'

    ## TEMPORARILY BYPASSING iterate_raw_query B/C IT'S DOING BIG JOB NOW ##
    # iterate_raw_query(raw_query) # via ComplexQueryIterator
    raw_query.each { |id| template_starter(id) }
  end

  #############################################
  ## ComplexQueryIterator takes raw_query and creates series of forked iterations based on limits established above in initialize method.  Then it calls 'template_starter(id)' method.  Module serves as bridge for iteration work.
  #############################################

  def template_starter(id)

    # @temp_sts = @web_obj.temp_sts  # After migration, uncomment.
    @web_obj = Web.find(id)
    @url = @web_obj.url
    @current_template = @web_obj.templates&.first&.template_name
    # criteria_term = nil

    start_noko(@url) ## Returns @html = @agent.get(url_string) from Noko
    html = @html

# Call: TemplateFinder.new.start_template_finder

    begin
      terms = Term.where(category: "template_finder").where(sub_category: "at_css")
      terms.map { |term| @new_template = term.response_term if html.at_css('html').text.include?(term.criteria_term) }
      @new_template = "Unidentified" if !@new_template.present?

      if @current_template != @new_template
        puts "\n@current_template: #{@current_template}"
        puts "@new_template: #{@new_template}"
        binding.pry
      end

      ## STOP HERE ##
      return
      update_db(id)


      # template_terms = Term.where(category: "template_finder").where(sub_category: "at_css")
      # template_terms.each do |template_term|
      #   criteria_term = template_term.criteria_term
      #
      #   if html.at_css('html').text.include?(criteria_term)
      #     @new_template = template_term.response_term
      #     update_db(id)
      #   else
      #     @new_template = "Unidentified"
      #     update_db(id)
      #   end
      # end

    rescue
      @new_template = @error_code
      binding.pry

      update_db(id)
    end

  end

  # def db_updater(id)
  def update_db(id)

    puts "\n\n@new_template: #{@new_template}"
    binding.pry

    get_result_sts
    puts "\n\n#{"="*30}\ntemplate_sts: '#{@template_sts}'\nurl: '#{@url}'\ncurrent_template: '#{@current_template}'\nnew_template: '#{@new_template}'\n\n"

    @indexer.update_attributes(indexer_sts: "TemplateFinder", template: @new_template, template_date: DateTime.now, template_sts: @template_sts)

    if id == @last_id
      puts "\n\n===== Last ID: #{id}===== \n\n"
      tf_starter
    end
  end

  def get_result_sts
    @current_template = @indexer.template
    if @current_template && @current_template == @new_template
      @template_sts = "Same"
    else
      @template_sts = "Updated"
    end
  end

end
