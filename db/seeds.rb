admin_role = UserRole.find_or_create_by!(label: "Admin") { |r| r.is_admin = true }
member_role = UserRole.find_or_create_by!(label: "Não-admin") { |r| r.is_admin = false }

admin = User.find_or_initialize_by(email: "admin@example.com")
admin.assign_attributes(
  full_name: "Usuário Admin",
  password: "password123",
  password_confirmation: "password123",
  user_role: admin_role
)
admin.save!

member = User.find_or_initialize_by(email: "user@example.com")
member.assign_attributes(
  full_name: "Usuário Comum",
  password: "password123",
  password_confirmation: "password123",
  user_role: member_role
)
member.save!

puts "Usuários criados:"
puts "  Admin  -> admin@example.com / password123"
puts "  Comum  -> user@example.com / password123"
