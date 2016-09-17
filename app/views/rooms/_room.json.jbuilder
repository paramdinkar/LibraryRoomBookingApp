json.extract! room, :id, :room_number, :building, :size, :status, :created_at, :updated_at
json.url room_url(room, format: :json)