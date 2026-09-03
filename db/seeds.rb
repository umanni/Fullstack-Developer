# frozen_string_literal: true

puts "Seeding Umanni Users…"

admin = User.find_or_initialize_by(email_address: "admin@umanni.test")
admin.assign_attributes(
  full_name: "Ada Admin",
  password: "password123",
  password_confirmation: "password123",
  role: :admin,
  avatar_url: "https://api.dicebear.com/9.x/initials/svg?seed=Ada%20Admin"
)
admin.save!

member = User.find_or_initialize_by(email_address: "user@umanni.test")
member.assign_attributes(
  full_name: "Morgan Member",
  password: "password123",
  password_confirmation: "password123",
  role: :member,
  avatar_url: "https://api.dicebear.com/9.x/initials/svg?seed=Morgan%20Member"
)
member.save!

%w[Alex Jordan Casey Riley Quinn].each_with_index do |name, index|
  user = User.find_or_initialize_by(email_address: "#{name.downcase}@example.com")
  user.assign_attributes(
    full_name: "#{name} Example",
    password: "password123",
    password_confirmation: "password123",
    role: :member,
    avatar_url: "https://api.dicebear.com/9.x/initials/svg?seed=#{name}"
  )
  user.save!
  print "." if index
end

puts "\nSeeded users: #{User.count}"
puts "Admin login: admin@umanni.test / password123"
puts "Member login: user@umanni.test / password123"
