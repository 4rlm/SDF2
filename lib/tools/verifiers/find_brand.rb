#CALL: FindBrand.new.start_find_brand

require 'iter_query'
require 'noko'

class FindBrand
  include IterQuery
  include Noko

  def initialize
    @brand_terms = BrandTerm.all
    @brands = Brand.all
    @dj_on = true
    @dj_count_limit = 0
    @dj_workers = 3
    @obj_in_grp = 10
    @dj_refresh_interval = 10
    @db_timeout_limit = 120
    @cut_off = 10.days.ago
    @current_process = "FindBrand"
  end


  def get_query
    query = Web.select(:id)
      .where('brand_date < ? OR brand_date IS NULL', @cut_off)
      .order("updated_at ASC").pluck(:id)
  end


  # def start_find_brand
  #   get_query.each { |id| template_starter(id) }
  # end


  def start_find_brand
    query = get_query[0..20]
    while query.any?
      setup_iterator(query)
      query = get_query[0..20]
      break if !query.any?
    end
  end


  def setup_iterator(query)
    @query_count = query.count
    (@query_count & @query_count > @obj_in_grp) ? @group_count = (@query_count / @obj_in_grp) : @group_count = 2
    @dj_on ? iterate_query(query) : query.each { |id| template_starter(id) }
  end


  def template_starter(id)
    web = Web.find(id)
    url = web.url
    brands = []
    url = web.url
    host = URI(url)&.host if url.present?
    names = web.acts&.map {|act| act&.act_name&.downcase&.split(' ')}
    host&.include?('www') ? names << host&.split('.')[1] : names << host&.split(' ')
    names.flatten!
    names.reject!(&:blank?)

    if names.present?
      names.each do |act_name|
        @brand_terms.each do |bt|
          brands << bt.brand_name if act_name.include?(bt.brand_term)
        end
      end

      brands&.uniq!
      current_brands = web.brands.map(&:brand_name)
      brands -= current_brands if current_brands.any?

      if brands.any?
        web.brands << Brand.where(brand_name: [brands])
      end
    end

    web.update(brand_date: Time.now)
  end


end

#CALL: FindBrand.new.start_find_brand
