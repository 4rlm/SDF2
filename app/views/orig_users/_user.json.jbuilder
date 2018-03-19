json.extract! user, :id, :username, :email, :pw_hash, :created_at, :updated_at
json.url user_url(user, format: :json)
