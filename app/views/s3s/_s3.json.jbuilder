json.extract! s3, :id, :created_at, :updated_at
json.url s3_url(s3, format: :json)
