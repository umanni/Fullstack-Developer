# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# docker compose up -d
# docker compose exec web rails db:seed
require 'faker'

puts "🧹 Limpando banco de dados..."
User.destroy_all

puts "👑 Criando administrador..."
admin = User.create!(
  full_name: "Administrador",
  email: "admin@email",
  password: "123456",
  password_confirmation: "123456",
  role: :admin
)

puts "✅ Admin criado: #{admin.email}"

puts "👥 Criando usuários comuns..."
3.times do
  user = User.create!(
    full_name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "123456",
    password_confirmation: "123456",
    role: :user
  )

  # Avatar aleatório via URL (usando LoremFlickr)
  file = URI.open("https://loremflickr.com/300/300/portrait?lock=#{rand(1..9999)}")
  user.avatar.attach(io: file, filename: "avatar_#{user.id}.jpg", content_type: 'image/jpeg')

  puts "👤 Criado usuário: #{user.full_name} (#{user.email})"
end

puts "🎉 Seeds finalizados com sucesso!"
puts "Login do admin: admin@email / senha: 123456"
