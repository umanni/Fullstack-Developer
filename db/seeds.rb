# ------------------------------------------------------------------------------
# Seed: validates the model structure (IAM users + user imports).
# Idempotent: safe to run multiple times via `bin/rails db:seed`.
#
# Production guard: the container entrypoint runs `db:prepare` on boot, so
# seeds would run on a fresh production volume. Never create reference
# credentials with a default password in production. Seeds run in production
# only when explicitly allowed AND with real admin credentials supplied via env.
# ------------------------------------------------------------------------------

if Rails.env.production?
  unless ENV.fetch("SEED_ALLOW_IN_PRODUCTION", "false") == "true"
    puts "Skipping seeds in production. Set SEED_ALLOW_IN_PRODUCTION=true and provide SEED_ADMIN_EMAIL/SEED_ADMIN_PASSWORD to run."
    return
  end
end

def seed_admin_email
  Rails.env.production? ? ENV.fetch("SEED_ADMIN_EMAIL") : ENV.fetch("SEED_ADMIN_EMAIL", "admin@iam.local")
end

def seed_admin_password
  Rails.env.production? ? ENV.fetch("SEED_ADMIN_PASSWORD") : ENV.fetch("SEED_ADMIN_PASSWORD", "Password123!")
end

def seed_admin
  User.find_or_create_by!(email_address: seed_admin_email) do |u|
    u.password = seed_admin_password
    u.full_name = "Ivy Admin"
    u.role = :admin
    u.avatar_url = "https://consolidesuamarca-voice.s3.us-east-2.amazonaws.com/assets/base/07e/c0c/7e0/exemplos-referencias-logomarcas-famosas-shell.jpg"
  end
end

def seed_regular_user
  User.find_or_create_by!(email_address: "user@iam.local") do |u|
    u.password = "Password123!"
    u.full_name = "Ursula User"
    u.role = :user
    u.avatar_url = "https://i.ytimg.com/vi/ux47qw1Mhck/sddefault.jpg"
  end
end

def seed_session(user, ip: "127.0.0.1", agent: "seed/1.0")
  user.sessions.create!(ip_address: ip, user_agent: agent)
end

def seed_user_import(user, status: :completed, total: 5, processed: 5, failed: 0)
  import = user.user_imports.build(
    status: status,
    total_rows: total,
    processed_rows: processed,
    failed_rows: failed,
    finished_at: Time.current
  )
  import.file.attach(
    io: StringIO.new("full_name,email_address,avatar_url\nSeed User,seed@iam.local,https://example.com/avatars/seed.png\n"),
    filename: "seed.csv",
    content_type: "text/csv"
  )
  import.save!
  import
end

def validate_models!
  checks = []

  admin = User.find_by!(email_address: "admin@iam.local")
  user = User.find_by!(email_address: "user@iam.local")

  checks << [ "User#admin? true", admin.admin? ]
  checks << [ "User#user? true", user.user? ]
  checks << [ "Admin avatar_source is remote URL", admin.avatar_source == admin.avatar_url ]
  checks << [ "Admin has sessions (#{admin.sessions.count})", admin.sessions.exists? ]
  checks << [ "Admin has user_imports (#{admin.user_imports.count})", admin.user_imports.exists? ]

  User.all.each do |record|
    checks << [ "User login validates (#{record.email_address})", record.valid? ]
    checks << [ "User avatar present via URL", record.avatar_source.present? ]
  end

  failed = checks.reject { |_desc, ok| ok }
  passed = checks.count - failed.size

  puts "\nSeed validation summary: #{passed}/#{checks.count} checks passed"
  unless failed.empty?
    failed.each { |desc, _| warn "  FAILED: #{desc}" }
    raise "Seed model validation failed"
  end
end

# --- Run ---------------------------------------------------------------------
admin = seed_admin
user = seed_regular_user

seed_session(admin)
seed_session(user)
seed_user_import(admin, status: :completed, total: 5, processed: 5)
seed_user_import(admin, status: :failed, total: 2, processed: 1, failed: 1)

validate_models!

puts "Seeds seeded successfully:"
puts "  Admin:        #{admin.email_address} (#{admin.role})"
puts "  User:         #{user.email_address} (#{user.role})"
puts "  Total users:  #{User.count}"
puts "  User imports: #{UserImport.count}"
