json.set! :books do
  json.array! @books do |book|
    json.extract! book, :id, :title, :author, :publisher, :genre, :release_at
  end
end