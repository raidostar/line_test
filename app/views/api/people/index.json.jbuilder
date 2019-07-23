json.set! :people do
  json.array! @people do |person|
    json.extract! person, :name, :gender, :age, :join_in
  end
end