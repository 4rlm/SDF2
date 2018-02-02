module ActsHelper


  ## Splits 'cont_any' strings into array, if string and has ','
  def split_ransack_params(params)
    act_name = params[:act_name_cont_any]
    state = params[:adrs_state_cont_any]
    phone = params[:phones_phone_cont_any]
    url = params[:webs_url_cont_any]

    params[:act_name_cont_any] = ransack_splitter(act_name) if act_name
    params[:adrs_state_cont_any] = ransack_splitter(state) if state
    params[:phones_phone_cont_any] = ransack_splitter(phone) if phone
    params[:webs_url_cont_any] = ransack_splitter(url) if url
    return params
  end


  def ransack_splitter(field)
    field = field.split(',').map{|part| part.strip} if field.is_a?(String)
    return field
  end

end
