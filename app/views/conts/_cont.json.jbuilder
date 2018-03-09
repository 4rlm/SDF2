json.extract! cont, :id, :first_name, :last_name, :full_name, :job_title, :job_desc, :email, :phone, :cs_sts, :cs_date, :email_changed, :cont_changed, :job_changed, :cx_date, :web_id, :created_at, :updated_at
json.url cont_url(cont, format: :json)
