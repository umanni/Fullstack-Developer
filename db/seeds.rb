# The container entrypoint runs db:prepare, which seeds a database it just created —
# so without this guard a production deploy comes up with a published password in it.
unless Rails.env.local?
  puts "Skipping demo seeds outside development and test."
  exit
end

DEMO_USER_COUNT = 32
PASSWORD = "secret-password".freeze

# Fixed so that two people who seed get the same dashboard. Without it the role split is
# a different number every run, and the first thing this application shows is a count.
Faker::Config.random = Random.new(20_260_903)

[
  { full_name: "Grace Hopper", email: "admin@umanni.test", role: :admin },
  { full_name: "Ada Lovelace", email: "user@umanni.test", role: :user }
].each do |attributes|
  User.find_or_create_by!(email: attributes[:email]) do |user|
    user.assign_attributes(attributes.merge(password: PASSWORD, password_confirmation: PASSWORD))
  end
end

# Driven by the total, so a second run is a no-op rather than thirty more people.
while User.count < DEMO_USER_COUNT
  User.create!(
    full_name: Faker::Name.name,
    email: Faker::Internet.unique.email(domain: "umanni.test"),
    role: Faker::Boolean.boolean(true_ratio: 0.2) ? :admin : :user,
    password: PASSWORD,
    password_confirmation: PASSWORD
  )
end

puts "Seeded #{User.count} users (#{User.admin.count} admins). Password for all: #{PASSWORD}"
