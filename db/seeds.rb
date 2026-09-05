# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Registration always forces role: no_admin (see RegistrationsController), so there is no way to
# reach an admin account from the UI alone. Seed one bootstrap admin so the app is usable right
# after setup.
User.find_or_create_by!(email: "admin@example.com") do |user|
  user.full_name = "Admin"
  user.password = "password123"
  user.role = :admin
end

# A regular (non-admin) user, seeded for convenience so the app has something to
# sign in as beyond the admin account right after setup.
User.find_or_create_by!(email: "user@example.com") do |user|
  user.full_name = "User"
  user.password = "password123"
  user.role = :no_admin
end
