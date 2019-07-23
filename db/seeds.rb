# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

20.times do
  Book.create(
    title: Faker::Book.title,
    author: Faker::Book.author,
    publisher: Faker::Book.publisher,
    genre: Faker::Book.genre,
  )
end

100.times do
  Person.create(
    name: Faker::Name.last_name,
    gender: Faker::Gender.binary_type,
    age: Faker::Number.between(20, 45),
    join_in: Faker::Date.between(1.year.ago, Date.today)
  )
end
