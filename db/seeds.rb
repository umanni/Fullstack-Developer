# Idempotent seeds: running this repeatedly converges on the same data instead
# of piling up duplicates.
#
# `db:prepare` runs this file, and in production that happens while the first
# container is booting -- so nothing here may abort. A seed that has nothing to
# do says so and lets the application start.

def upsert_user!(email_address:, full_name:, role:, password:, locale: "en")
  user = User.find_or_initialize_by(email_address: email_address)
  user.assign_attributes(full_name: full_name, role: role, locale: locale)
  user.password = password if user.new_record?
  user.save!
  user
end

# ── Production ───────────────────────────────────────────────────────────────
# One administrator, from credentials supplied at deploy time, and nothing
# else. The demonstration roster below shares a single known password, which
# has no business existing on a real installation.
if Rails.env.production?
  email_address = ENV["SEED_ADMIN_EMAIL"].presence
  password = ENV["SEED_ADMIN_PASSWORD"].presence

  if email_address && password
    upsert_user!(
      email_address: email_address,
      full_name: ENV.fetch("SEED_ADMIN_NAME", "Administrator"),
      role: :admin,
      password: password
    )
    Rails.logger.info { "Seeded the administrator account #{email_address}." }
  else
    Rails.logger.info do
      "Skipping seeds: set SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD to create the first administrator."
    end
  end

  return
end

# ── Everywhere else ──────────────────────────────────────────────────────────
DEMO_PASSWORD = ENV.fetch("SEED_ADMIN_PASSWORD", "password-for-development")

upsert_user!(email_address: "admin@example.com", full_name: "Ada Lovelace",
             role: :admin, password: DEMO_PASSWORD)
upsert_user!(email_address: "admin.two@example.com", full_name: "Grace Hopper",
             role: :admin, password: DEMO_PASSWORD)
upsert_user!(email_address: "user@example.com", full_name: "Maria Silva",
             role: :user, password: DEMO_PASSWORD, locale: "pt-BR")

[
  ["joao.souza@example.com",     "João Souza",        "pt-BR"],
  ["carla.mendes@example.com",   "Carla Mendes",      "pt-BR"],
  ["diego.ramirez@example.com",  "Diego Ramírez",     "es"],
  ["lucia.fernandez@example.com", "Lucía Fernández",  "es"],
  ["olivia.clarke@example.com",  "Olivia Clarke",     "en"],
  ["noah.bennett@example.com",   "Noah Bennett",      "en"],
  ["priya.nair@example.com",     "Priya Nair",        "en"],
  ["tomas.novak@example.com",    "Tomáš Novák",       "en"],
  ["yuki.tanaka@example.com",    "Yuki Tanaka",       "en"],
  ["amara.okafor@example.com",   "Amara Okafor",      "en"]
].each do |email_address, full_name, locale|
  upsert_user!(email_address: email_address, full_name: full_name,
               role: :user, password: DEMO_PASSWORD, locale: locale)
end

Rails.logger.debug { "Seeded #{User.count} users (#{User.admin.count} administrators)." }
