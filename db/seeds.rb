# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user
admin = User.find_or_initialize_by(email: 'admin@example.com')
admin.assign_attributes(
  full_name: 'Admin User',
  password: 'password123',
  password_confirmation: 'password123',
  role: :admin
)
admin.save!

puts "Admin user #{admin.persisted? ? 'updated' : 'created'}: #{admin.email}"

# Create some sample users
10.times do |i|
  user = User.find_or_initialize_by(email: "user#{i + 1}@example.com")
  user.assign_attributes(
    full_name: Faker::Name.name,
    password: 'password123',
    password_confirmation: 'password123',
    role: :user
  )
  user.save!
end

puts "Sample users created"

