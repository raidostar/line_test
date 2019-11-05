json.set! :bubbles do
  json.array! @bubbles do |bubble|
    json.extract! bubble, :id, :header, :hero, :body, :footer_type, :footer, :created_at, :updated_at
  end
end