json.extract! admin, :id, :name, :password, :email, :created_at, :updated_at
json.url admin_url(admin, format: :json)