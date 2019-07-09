json.set! :book do
  json.extract! @book, :id, :title, :author, :publisher, :genre
end