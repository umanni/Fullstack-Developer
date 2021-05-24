# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Clearing DB..."
User.destroy_all

puts "Creating users..."

Igor = User.create!(
    full_name: 'Igor Amus',
    avatar_image: 'https://i.imgur.com/XMCwHDt.jpg',
    email: 'igor@amus.com',
    password: '1234567890',
    role: false
)

Jessica = User.create!(
    full_name: 'Jessica Chan',
    avatar_image: 'https://i.imgur.com/7uzj23o.jpg',
    email: 'jessica@chan.com',
    password: '1234567890',
    role: true
)

Fabio = User.create!(
    full_name: 'Fabio Corona',
    avatar_image: 'https://i.imgur.com/id5juIo.jpg',
    email: 'fabio@corona.com',
    password: '1234567890',
    role: true
)

Tribecca = User.create!(
    full_name: 'Tribecca Sultana',
    avatar_image: 'https://i.imgur.com/UF1Zm3m.jpg',
    email: 'tribecca@sultana.com',
    password: '1234567890',
    role: false
)

Mickey = User.create!(
    full_name: 'Mickey Laws',
    avatar_image: 'https://i.imgur.com/V0Iuqkr.jpg',
    email: 'mickey@laws.com',
    password: '1234567890',
    role: true
)

Juul = User.create!(
    full_name: 'Juul Finn',
    avatar_image: 'https://i.imgur.com/NJCqPIb.jpg',
    email: 'juul@finn.com',
    password: '1234567890',
    role: false
)