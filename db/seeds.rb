# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 Seeding database..."

# Create admin user
admin_email = "admin@example.com"
admin_user = User.find_or_initialize_by(email: admin_email)

if admin_user.new_record?
  admin_user.assign_attributes(
    full_name: "Administrator",
    role: "admin",
    password: "password123",
    password_confirmation: "password123"
  )

  if admin_user.save
    puts "✅ Admin user created successfully!"
    puts "   Email: #{admin_user.email}"
    puts "   Password: password123"
    puts "   Role: #{admin_user.role}"
  else
    puts "❌ Failed to create admin user:"
    admin_user.errors.full_messages.each do |error|
      puts "   - #{error}"
    end
  end
else
  puts "ℹ️  Admin user already exists (#{admin_email})"
end

# Create some sample regular users for testing
sample_users = [
  {
    full_name: "João Silva",
    email: "joao@example.com",
    role: "user"
  },
  {
    full_name: "Maria Santos",
    email: "maria@example.com",
    role: "user"
  },
  {
    full_name: "Pedro Oliveira",
    email: "pedro@example.com",
    role: "user"
  }
]

puts "\n👥 Creating sample users..."

sample_users.each do |user_data|
  user = User.find_or_initialize_by(email: user_data[:email])

  if user.new_record?
    user.assign_attributes(
      full_name: user_data[:full_name],
      role: user_data[:role],
      password: "password123",
      password_confirmation: "password123"
    )

    if user.save
      puts "✅ Created user: #{user.full_name} (#{user.email})"
    else
      puts "❌ Failed to create user #{user_data[:email]}:"
      user.errors.full_messages.each do |error|
        puts "   - #{error}"
      end
    end
  else
    puts "ℹ️  User already exists: #{user_data[:email]}"
  end
end

puts "\n📊 Database summary:"
puts "   Total users: #{User.count}"
puts "   Admin users: #{User.admin.count}"
puts "   Regular users: #{User.user.count}"

puts "\n🎉 Seeding completed!"
