json.set! :book do
  json.extract! @book, :title, :author, :publisher, :genre
end