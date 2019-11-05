json.set! :bubble do
  json.extract! @bubble, :id, :header, :hero, :body, :footer_type, :footer, :created_at, :updated_at
end