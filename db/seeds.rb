admin_email = ENV.fetch("SEED_ADMIN_EMAIL", "admin@example.com")
admin = User.find_or_initialize_by(email: admin_email)

if admin.persisted?
  admin.update!(role: :admin) unless admin.admin?
  puts "Administrator already present: #{admin.email}"
else
  if Rails.env.production? && ENV["SEED_ADMIN_PASSWORD"].blank?
    raise "SEED_ADMIN_PASSWORD must be set when creating the production administrator"
  end

  password = ENV.fetch("SEED_ADMIN_PASSWORD", "ChangeMeNow!123")
  admin.assign_attributes(
    full_name: ENV.fetch("SEED_ADMIN_NAME", "PeopleHub Admin"),
    role: :admin,
    password: password,
    password_confirmation: password
  )
  admin.save!

  puts "Seeded administrator: #{admin.email}"
end
