json.extract! account, :id, :source, :status, :crm_acct_num, :name, :created_at, :updated_at
json.url account_url(account, format: :json)
