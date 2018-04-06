module ContsHelper

  ## Splits 'cont_any' strings into array, if string and has ','
  def split_ransack_params(params)
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


    # CONTS
    full_name = params[:full_name_cont_any]
    first_name = params[:first_name_cont_any]
    last_name = params[:last_name_cont_any]
    job_title = params[:job_title_cont_any]
    job_desc = params[:job_desc_cont_any]
    email = params[:email_cont_any]
    phone = params[:phone_cont_any]

    params[:full_name_cont_any] = ransack_splitter(full_name) if full_name
    params[:first_name_cont_any] = ransack_splitter(first_name) if first_name
    params[:last_name_cont_any] = ransack_splitter(last_name) if last_name
    params[:job_title_cont_any] = ransack_splitter(job_title) if job_title
    params[:job_desc_cont_any] = ransack_splitter(job_desc) if job_desc
    params[:email_cont_any] = ransack_splitter(email) if email
    params[:phone_cont_any] = ransack_splitter(phone) if phone

    # WEBS
    web_url = params[:web_url_cont_any]
    web_fwd_url = params[:web_fwd_url_cont_any]

    params[:web_url_cont_any] = ransack_splitter(web_url) if web_url
    params[:web_fwd_url_cont_any] = ransack_splitter(web_fwd_url) if web_fwd_url

    return params
  end


  def ransack_splitter(field)
    field = field.split(',').map{|part| part.strip} if field.is_a?(String)
    return field
  end

end
