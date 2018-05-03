module ApplicationHelper


  def sortable(column, title = nil)
    title ||= column.titleize

    if column != sort_column
      css_class = nil
    else
      sort_direction == "asc" ? css_class = "fa fa-chevron-up fa-lg" : css_class = "fa fa-chevron-down fa-lg"
    end

    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    # link_to "#{title}  <i class='#{css_class}'></i>".html_safe, {sort: column, direction: direction}
    # "#{title}  <i class='#{css_class}'></i>".html_safe

  end




  ## GET_BRANDS_FOR_SELECT - STARTS
  def get_brands(web)
    if web.present?
      brands = web.brands.select {|brand| brand.brand_name}.pluck(:brand_name)
    end
  end


  ## GET_STATES_FOR_SELECT - STARTS
  def get_state(acts)
    if acts.any?
      # states = acts.map {|act| act.state}&.pluck(:state)&.flatten&.uniq
      states = acts.map(&:state)
    end
  end


  ## GET_GP_STS - STARTS
  def get_gp_stss(acts)
    if acts.any?
      gp_stss = acts.select {|act| act&.gp_sts}.pluck(:gp_sts)&.flatten&.uniq
    end
  end


  ## GET_GP_INDUSS - STARTS
  def get_gp_induss(acts)
    if acts.any?
      gp_induss = acts.select {|act| act&.gp_indus}.pluck(:gp_indus)&.flatten&.uniq
    end
  end


  def generate_ransack_web_options
    web_opts = {
      temps: ['All Auto Network', 'AutoJini', 'Autofunds', 'Autofusion', 'Chapman.co', 'Cobalt', 'DEALER eProcess', 'DLD Websites', 'Dealer Direct', 'Dealer Inspire', 'Dealer Socket', 'Dealer Spike', 'Dealer.com', 'DealerCar Search', 'DealerFire', 'DealerOn', 'DealerPeak', 'DealerTrend', 'Dominion', 'Drive Website', 'Driving Force', 'FoxDealer', 'I/O COM', 'Jazel Auto', 'Motion Fuze', 'Motorwebs', 'Pixel Motion', 'Remora', 'SERPCOM', 'Search Optics', 'Slip Stream', 'VinSolutions', 'eBizAutos', 'fusionZONE', 'fusionZone'],

      brands: ['Acura', 'Alfa Romeo', 'Aston Martin', 'Audi', 'BMW', 'Bentley', 'Bugatti', 'Buick', 'CDJR', 'Cadillac', 'Chevrolet', 'Chrysler', 'Dodge', 'Ferrari', 'Fiat', 'Ford', 'GMC', 'Group', 'Honda', 'Hummer', 'Hyundai', 'Infiniti', 'Isuzu', 'Jaguar', 'Jeep', 'Kia', 'Lamborghini', 'Land Rover', 'Lexus', 'Lincoln', 'Lotus', 'MINI', 'Maserati', 'Mazda', 'Mclaren', 'Mercedes-Benz', 'Mitsubishi', 'Nissan', 'Porsche', 'Ram', 'Rolls-Royce', 'Saab', 'Scion', 'Smart', 'Subaru', 'Suzuki', 'Toyota', 'Volkswagen', 'Volvo'],

      cops: [true, false],
      url_stss: Web.all.map(&:url_sts).uniq.compact.sort,
      temp_stss: Web.all.map(&:temp_sts).uniq.compact.sort,
      page_stss: Web.all.map(&:page_sts).uniq.compact.sort,
      cs_stss: Web.all.map(&:cs_sts).uniq.compact.sort
    }
  end


  def get_ransack_web_opts
    ransack_web_options = RansackOption.find_by(mod_name: 'Web')
    ransack_web_options = RansackOption.create(mod_name: 'Web', option_hsh: generate_ransack_web_options) if !ransack_web_options.present?
    web_opts = ransack_web_options[:option_hsh]
  end


  def generate_ransack_act_options
    act_opts = {
      states: %w(AK AL AR AZ CA CO CT DC DE FL GA GU HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA PR RI SC SD TN TX UT VA VT WA WI WV WY),
      gp_stss: Act.all.map(&:gp_sts).uniq.compact.sort
    }
  end


  def get_ransack_act_opts
    ransack_act_options = RansackOption.find_by(mod_name: 'Act')
    ransack_act_options = RansackOption.create(mod_name: 'Act', option_hsh: generate_ransack_act_options) if !ransack_act_options.present?
    act_opts = ransack_act_options[:option_hsh]
  end


  def generate_ransack_cont_options
    col_tallies_hsh = GenTally.get_col_tally2('Cont', 'job_title')
    common_titles_hsh =  col_tallies_hsh[:job_title][0..29]
    hsh = common_titles_hsh.map { |h| h.slice(:item) }
    common_titles = hsh.map {|h| h[:item] }

    web_opts = {
      target_titles: ['BDC Manager', 'COO', 'Director', 'Executive', 'Fixed Operations', 'Fixed Operations Director', 'Fixed Operations Manager', 'General Manager', 'Manager', 'Marketing Director', 'Marketing Manager', 'New Car Director', 'New Car Manager', 'Operations Director', 'Operations Manager', 'Owner/Prin/Pres', 'Sales Director', 'Sales Manager', 'Used Car Director', 'Used Car Manager', 'Used Car Manager (Asst)', 'VP Operations', 'Variable Operations Director', 'Vice President'],
      common_titles: common_titles
    }
  end


  def get_ransack_cont_opts
    ransack_cont_options = RansackOption.find_by(mod_name: 'Cont')
    ransack_cont_options = RansackOption.create(mod_name: 'Cont', option_hsh: generate_ransack_cont_options) if !ransack_cont_options.present?
    cont_opts = ransack_cont_options[:option_hsh]
  end


end
