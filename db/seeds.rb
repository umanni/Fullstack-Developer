# Seeds are idempotent and safe for every environment (dev/test/prod).
# Load with bin/rails db:seed (created alongside DB with db:setup).
# CI runs env RAILS_ENV=test bin/rails db:seed:replant.

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.full_name = "Site Admin"
  u.password = "Password123"
  u.password_confirmation = "Password123"
  u.role = :admin
end
puts "admin: #{admin.email} (#{admin.role})"

[
  [ "Ada Lovelace", "ada@example.com" ],
  [ "Alan Turing", "alan@example.com" ],
  [ "Grace Hopper", "grace@example.com" ],
  [ "Margaret Hamilton", "margaret@example.com" ]
].each do |full_name, email|
  user = User.find_or_create_by!(email: email) do |u|
    u.full_name = full_name
    u.password = "Password123"
    u.password_confirmation = "Password123"
    u.role = :user
  end
  puts "user: #{user.email} (#{user.role})"
end
