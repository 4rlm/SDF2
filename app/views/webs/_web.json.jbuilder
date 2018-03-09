json.extract! web, :id, :url, :url_sts_code, :cop, :temp_name, :url_sts, :temp_sts, :page_sts, :cs_sts, :brand_sts, :timeout, :url_date, :tmp_date, :page_date, :cs_date, :brand_date, :fwd_url, :web_changed, :wx_date, :created_at, :updated_at
json.url web_url(web, format: :json)
