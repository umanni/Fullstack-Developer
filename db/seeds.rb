# Idempotent seeds: running this repeatedly converges on the same data instead
# of piling up duplicates.
#
# The demonstration password is only ever allowed outside production. In
# production the seed refuses to invent credentials and expects
# SEED_ADMIN_PASSWORD to be supplied.

DEMO_PASSWORD = ENV.fetch("SEED_ADMIN_PASSWORD") do
  if Rails.env.production?
    abort "Set SEED_ADMIN_PASSWORD before seeding production."
  else
    "password-for-development"
  end
end

def upsert_user!(email_address:, full_name:, role:, locale: "en")
  user = User.find_or_initialize_by(email_address: email_address)
  user.assign_attributes(full_name: full_name, role: role, locale: locale)
  user.password = DEMO_PASSWORD if user.new_record?
  user.save!
  user
end

upsert_user!(email_address: "admin@example.com", full_name: "Ada Lovelace", role: :admin)
upsert_user!(email_address: "admin.two@example.com", full_name: "Grace Hopper", role: :admin)
upsert_user!(email_address: "user@example.com", full_name: "Maria Silva", role: :user, locale: "pt-BR")

[
  [ "joao.souza@example.com",     "João Souza",        "pt-BR" ],
  [ "carla.mendes@example.com",   "Carla Mendes",      "pt-BR" ],
  [ "diego.ramirez@example.com",  "Diego Ramírez",     "es" ],
  [ "lucia.fernandez@example.com", "Lucía Fernández",  "es" ],
  [ "olivia.clarke@example.com",  "Olivia Clarke",     "en" ],
  [ "noah.bennett@example.com",   "Noah Bennett",      "en" ],
  [ "priya.nair@example.com",     "Priya Nair",        "en" ],
  [ "tomas.novak@example.com",    "Tomáš Novák",       "en" ],
  [ "yuki.tanaka@example.com",    "Yuki Tanaka",       "en" ],
  [ "amara.okafor@example.com",   "Amara Okafor",      "en" ]
].each do |email_address, full_name, locale|
  upsert_user!(email_address: email_address, full_name: full_name, role: :user, locale: locale)
end

Rails.logger.debug { "Seeded #{User.count} users (#{User.admin.count} administrators)." }
