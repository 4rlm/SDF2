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

  def get_brands_for_select(webs)
    if webs.present?
      brands = webs.is_franchise&.map {|web| get_brands(web)}&.flatten&.uniq&.sort
    end
  end


  ## GET_STATES_FOR_SELECT - STARTS
  def get_state(acts)
    if acts.any?
      states = acts.select {|act| act&.state}.pluck(:state)&.flatten&.uniq
    end
  end

  def get_states_for_select(webs)
    if webs.present?
      states = webs.web_act_state&.map {|web| get_state(web&.acts)}&.flatten&.uniq&.sort
    end
  end


  ## GET_GP_STS - STARTS
  def get_gp_stss(acts)
    if acts.any?
      gp_stss = acts.select {|act| act&.gp_sts}.pluck(:gp_sts)&.flatten&.uniq
    end
  end

  def get_gp_stss_for_select(webs)
    if webs.present?
      gp_stss = webs.web_act_gp_sts&.map {|web| get_gp_stss(web&.acts)}&.flatten&.uniq&.sort
    end
  end


  ## GET_GP_INDUSS - STARTS
  def get_gp_induss(acts)
    if acts.any?
      gp_induss = acts.select {|act| act&.gp_indus}.pluck(:gp_indus)&.flatten&.uniq
    end
  end

  def get_gp_induss_for_select(webs)
    if webs.present?
      gp_induss = webs.web_act_gp_indus&.map {|web| get_gp_induss(web&.acts)}&.join(' ')&.split(' ')&.uniq&.sort
    end
  end


end
