# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# MODELO DE SEED
# require "open-uri"

# user = User.new
# user.full_name = "Ronaldo Nazário"
# user.email = 'ronaldo@umanni.com.br'
# user.password = '123123'
# user.role = false
# user.photo.attach(io: URI.open("https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Ronaldo_2002_cropped.jpg/220px-Ronaldo_2002_cropped.jpg"), filename: "avatar")
# user.save!

require "open-uri"

userAdmin = User.new
userAdmin.full_name = "Umanni"
userAdmin.email = 'contato@umanni.com.br'
userAdmin.password = '123123'
userAdmin.role = true
userAdmin.photo.attach(io: URI.open("https://www.umanni.com/content/images/2020/05/Logo-Umanni---U--Azul-.png"), filename: "avatar")
userAdmin.save!

userUser = User.new
userUser.full_name = "Pedro Padilha"
userUser.email = "pedropadilha@umanni.com.br"
userUser.password = '123123'
userUser.photo.attach(io: URI.open("https://media.licdn.com/dms/image/C4E03AQEusnyvVzPzmg/profile-displayphoto-shrink_200_200/0/1535915707657?e=1683763200&v=beta&t=fBVRWt9oEPV_dspDfuy0Hg0FZc2XDLSzPKsTDh9Iuk0"), filename: "avatar")
userUser.save!

(1..28).each do
  user = User.new
  user.full_name = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
  user.email = "#{user.full_name.downcase.gsub(" ","")}@umanni.com.br"
  user.password = '123123'
  user.photo.attach(io: URI.open("https://loremflickr.com/320/240/face"), filename: "avatar")
  user.save!
end
