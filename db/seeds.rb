admin = User.find_or_create_by!(email_address: "admin@umanni.test") do |user|
  user.full_name = "Umanni Admin"
  user.password  = ENV.fetch("SEED_ADMIN_PASSWORD", "password123")
  user.role      = :admin
end

25.times do
  User.find_or_create_by!(email_address: Faker::Internet.unique.email) do |user|
    user.full_name  = Faker::Name.name
    user.password   = "password123"
    user.role       = :member
    user.avatar_url = "https://i.pravatar.cc/300?u=#{SecureRandom.hex(4)}"
  end
end
