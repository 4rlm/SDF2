module WebsHelper

  ## Splits 'cont_any' strings into array, if string and has ','
  def split_ransack_params(params)
    # act_name = params[:act_name_cont_any]
    # city = params[:city_matches_any]
    # state = params[:state_cont_any]
    # zip = params[:zip_cont_any]
    # phone = params[:phone_cont_any]
    url = params[:url_cont_any]
    
    # params[:act_name_cont_any] = ransack_splitter(act_name) if act_name
    # params[:city_matches_any] = ransack_splitter(city) if city
    # params[:state_cont_any] = ransack_splitter(state) if state
    # params[:zip_cont_any] = ransack_splitter(zip) if zip
    # params[:phone_cont_any] = ransack_splitter(phone) if phone
    params[:url_cont_any] = ransack_splitter(url) if url
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
