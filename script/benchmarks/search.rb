# Reproduces the numbers the README quotes for the search index.
#
#   bin/rails runner script/benchmarks/search.rb
#
# Needs a roster large enough for the planner to have a choice. To generate one:
#
#   digest = BCrypt::Password.create("benchmark-only", cost: 4)
#   User.insert_all(50_000.times.map { |i|
#     { full_name: "#{Faker::Name.name} #{i}", email_address: "bench#{i}@example.com",
#       password_digest: digest, role: 0, locale: "en",
#       created_at: Time.current, updated_at: Time.current } })
#
# and to remove them afterwards:
#
#   User.where("email_address LIKE ?", "bench%").delete_all
#
# Development only -- this script reads, it does not write.
connection = ActiveRecord::Base.connection
connection.execute("ANALYZE users")

def timing(connection, sql)
  connection.select_values("EXPLAIN (ANALYZE, TIMING OFF) #{sql}")
end

puts "rows: #{User.count}"

%w[silva ma].each do |term|
  sql = User.search(term).to_sql
  puts "\n=== term #{term.inspect} (#{term.length} characters) ==="

  connection.execute("SET enable_bitmapscan = on; SET enable_indexscan = on")
  with_index = timing(connection, sql)
  puts "with the index:    #{with_index.first.split("(cost").first.strip}"
  puts "                   #{with_index.grep(/Execution Time/).first}"

  connection.execute("SET enable_bitmapscan = off; SET enable_indexscan = off")
  without = timing(connection, sql)
  puts "sequential scan:   #{without.first.split("(cost").first.strip}"
  puts "                   #{without.grep(/Execution Time/).first}"
end
