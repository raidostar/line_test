json.set! :book do
  json.extract! @book, :title, :author, :publisher, :genre, :release_at
end