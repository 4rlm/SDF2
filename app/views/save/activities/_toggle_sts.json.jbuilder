# json.extract! toggle_sts, :id, :user_id, :export_id, :mod_name, :mod_id, :fav_sts, :created_at, :updated_at, :hide_sts, :created_at, :updated_at
# json.url toggle_sts_url(toggle_sts, format: :json)

json.extract! activity, :id, :user_id, :export_id, :mod_name, :mod_id, :fav_sts, :created_at, :updated_at, :hide_sts, :created_at, :updated_at
json.url activity_url(activity, format: :json)
