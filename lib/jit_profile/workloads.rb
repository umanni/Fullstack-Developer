require "csv"
require "tempfile"

module JitProfile
  # This app's hot paths, cut down to the part that runs in Ruby. Each builder does its setup
  # (which may read the schema) and returns a lambda that doesn't query the database, so the
  # timings compare JIT compilers rather than Postgres round trips.
  class Workloads
    NAMES = %w[serialize_users import_rows parse_csv render_page].freeze
    ROWS = 250
    # ApplicationController's allow_browser turns away requests without a modern user agent.
    USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 " \
                 "(KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36".freeze

    def build(name)
      raise ArgumentError, "Unknown workload #{name.inspect}, pick from: #{NAMES.join(", ")}" if NAMES.exclude?(name)

      public_send(name)
    end

    # UserSerializer over a page of users, as on the admin users table.
    def serialize_users
      users = Array.new(ROWS) do |i|
        User.new(id: i + 1, full_name: "User #{i}", email_address: "user#{i}@example.com",
                 role: i.even? ? :member : :admin, avatar_url: "https://cdn.example.com/#{i}.png",
                 created_at: Time.utc(2026, 1, 1) + i)
      end

      -> { UserSerializer.collection(users).to_json }
    end

    # Spreadsheet rows through header aliases, cell sanitising and validation (Imports::UserRow).
    def import_rows
      headers = Imports::UserRow.normalize_headers([ "Full Name", "E-mail", "Role", "Avatar" ])
      rows = Array.new(ROWS) do |i|
        [ " =User #{i} ", "User#{i}@Example.com", i.even? ? "member" : "admin", "https://cdn.example.com/#{i}.png" ]
      end

      -> { rows.map { |values| Imports::UserRow.from(headers, values).tap(&:valid?).to_user_attributes } }
    end

    # Imports::CsvRowSet reading a whole uploaded CSV.
    def parse_csv
      @csv = Tempfile.new([ "jit-profile-users", ".csv" ])
      CSV.open(@csv.path, "w") do |csv|
        csv << %w[full_name email_address role]
        ROWS.times { |i| csv << [ "User #{i}", "user#{i}@example.com", "member" ] }
      end
      path = @csv.path

      -> { Imports::CsvRowSet.new(path).count }
    end

    # One GET through the whole Rack stack: middleware, routing, RegistrationsController, the
    # Inertia renderer and the layout. The sign-up page needs no session, so no database read.
    def render_page
      env = { "HTTP_HOST" => "localhost", "HTTPS" => "on", "HTTP_USER_AGENT" => USER_AGENT }
      request = lambda do
        status, _headers, body = Rails.application.call(Rack::MockRequest.env_for("/registration/new", env))
        body.close if body.respond_to?(:close)
        status
      end

      status = request.call
      raise "GET /registration/new answered #{status}, expected 200" unless status == 200

      request
    end
  end
end
