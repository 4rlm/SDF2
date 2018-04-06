module WebsHelper

  ## Splits 'cont_any' strings into array, if string and has ','
  def split_ransack_params(params)
    # WEBS
    url = params[:url_cont_any]
    fwd_url = params[:fwd_url_cont_any]

    params[:url_cont_any] = ransack_splitter(url) if url
    params[:fwd_url_cont_any] = ransack_splitter(fwd_url) if fwd_url

    # ACTS
    acts_act_name = params[:acts_act_name_cont_any]
    acts_city = params[:acts_city_cont_any]
    acts_state = params[:acts_state_cont_any]
    acts_zip = params[:acts_zip_cont_any]
    acts_phone = params[:acts_phone_cont_any]
    acts_lat = params[:acts_lat_cont_any]
    acts_lon = params[:acts_lon_cont_any]
    acts_gp_id = params[:acts_gp_id_cont_any]

    params[:acts_act_name_cont_any] = ransack_splitter(acts_act_name) if acts_act_name
    params[:acts_city_cont_any] = ransack_splitter(acts_city) if acts_city
    params[:acts_state_cont_any] = ransack_splitter(acts_state) if acts_state
    params[:acts_zip_cont_any] = ransack_splitter(acts_zip) if acts_zip
    params[:acts_phone_cont_any] = ransack_splitter(acts_phone) if acts_phone
    params[:acts_lat_cont_any] = ransack_splitter(acts_lat) if acts_lat
    params[:acts_lon_cont_any] = ransack_splitter(acts_lon) if acts_lon
    params[:acts_gp_id_cont_any] = ransack_splitter(acts_gp_id) if acts_gp_id

    return params
  end


  def ransack_splitter(field)
    field = field.split(',').map{|part| part.strip} if field.is_a?(String)
    return field
  end

  def get_valid_act_names(acts)
    if acts.any?
      valid_act_names = acts.where.not(act_name: nil, gp_id: nil).map { |act| act.act_name }&.join(' || ')
    end
  end

  def get_valid_states(acts)
    if acts.any?
      valid_states = acts.where.not(state: nil, gp_id: nil).map { |act| act.state }&.join(' || ')
    end
  end

  def get_valid_cities(acts)
    if acts.any?
      valid_cities = acts.where.not(city: nil, gp_id: nil).map { |act| act.city }&.join(' || ')
    end
  end


end
