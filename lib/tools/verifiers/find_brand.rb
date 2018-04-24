#CALL: FindBrand.new.start_find_brand

class FindBrand

  def initialize
    @brand_terms = BrandTerm.all
    @brands = Brand.all
    @cut_off = 30.days.ago
  end


  def get_query
    query = Web.select(:id)
      .where('brand_date < ? OR brand_date IS NULL', @cut_off)
      .order("updated_at ASC").pluck(:id)

    puts "\n\nQuery Count: #{query.count}"
    query
  end


  def start_find_brand
    get_query.each { |id| template_starter(id) }
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
