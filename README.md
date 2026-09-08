### AI Usage Disclosure

This implementation was assisted by **OpenAI Codex (GPT-5)**. The code was reviewed and verified with automated checks.

# PeopleHub

PeopleHub is a Rails 8 user-management application with a React/Inertia frontend.

It supports:

- User registration and authentication.
- User profiles with avatar uploads.
- Admin user management and role changes.
- CSV/XLSX imports processed in the background.
- Live dashboard counters and import progress.

## 1. Requirements

You only need:

- Docker Desktop with Docker Compose.
- Git, if cloning the repository.

You do **not** need to install Ruby, Rails, Node.js, PostgreSQL, Redis, or `RAILS_MASTER_KEY` for the local Docker flow.

### Install Docker

- [Docker Desktop for macOS](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Docker Engine for Linux](https://docs.docker.com/engine/install/)

After installing Docker Desktop, open it and wait until it says that Docker is running.

Verify the installation:

```bash
docker --version
docker compose version
```

## 2. Start the application

Run these commands from the folder that contains `docker-compose.yml`:

```bash
docker compose up --build
```

The first build can take a few minutes. When the containers are ready, open:

- Application: <http://localhost:3000>
- Mailpit inbox: <http://localhost:18025>
- Import template: <http://localhost:3000/user_import_template.csv>

To run in the background:

```bash
docker compose up --build -d
```

To see the application logs:

```bash
docker compose logs -f web
```

Stop the containers without deleting data:

```bash
docker compose down
```

## 3. What Docker starts

| Service | Purpose |
| --- | --- |
| `db` | PostgreSQL 17 with WAL-safe settings. |
| `storage-init` | Prepares permissions for the persistent upload volume. |
| `setup` | Creates Solid databases, runs migrations, and runs the seed. |
| `web` | Runs Rails with Thruster and Puma. |
| `jobs` | Runs the Solid Queue worker. |
| `mailpit` | Captures local email without sending real email. |

No Redis installation is required. Solid Queue and Solid Cable use PostgreSQL.

### Why does the console say `production`?

The Docker image intentionally runs Rails with `RAILS_ENV=production` locally. This exercises the same production-shaped image used by Thruster and Kamal.

The data is still local: PostgreSQL, uploaded files, and Mailpit run in local Docker containers and volumes. This is not a connection to a remote production system.

## 4. Administrator account and seed

The seed file is:

```text
db/seeds.rb
```

The Docker setup automatically runs:

```bash
bin/rails db:prepare
bin/rails db:seed
```

Default local administrator:

```text
Email:    admin@example.com
Password: PeopleHub!123456
```

The seed is safe to run more than once. It creates the administrator if it does not exist and does not replace an existing administrator password.

Run it manually when needed:

```bash
docker compose exec web bin/rails db:seed
```

Use different credentials on a fresh setup:

```bash
SEED_ADMIN_EMAIL=admin@mycompany.com \
SEED_ADMIN_PASSWORD='A-strong-password-123' \
docker compose up --build
```

For the Rails console:

```bash
docker compose exec web bin/rails console
```

Example commands inside the console:

```ruby
User.count
User.order(:id).pluck(:id, :full_name, :email, :role)
```

Exit with:

```ruby
exit
```

## 5. Import users from a spreadsheet

The ready-to-use CSV template is located at:

```text
public/user_import_template.csv
```

It can also be downloaded from the application at:

<http://localhost:3000/user_import_template.csv>

The template contains these columns:

```csv
full_name,email,role
Ada Lovelace,ada@example.com,admin
Grace Hopper,grace@example.com,user
```

Rules:

- `full_name` is required.
- `email` is required and must be unique.
- `role` is optional and defaults to `user`.
- Valid roles are `user` and `admin`.
- The maximum file size is 10 MB.
- The maximum number of rows is 5,000.
- Both `.csv` and `.xlsx` files are accepted.

### Import flow

1. Sign in with the administrator account.
2. Open **Imports**.
3. Upload a CSV or XLSX file.
4. Open the import details page.
5. Follow the live progress and row errors.

The import is asynchronous. Solid Queue processes the file and Solid Cable broadcasts progress updates to the frontend.

Imported users receive a password-reset email. Because this is local development, the message is available in Mailpit at <http://localhost:18025>.

## 6. Main user flows

### Visitor

Open **Create an account** and register as a normal user.

### Standard user

After login, the user is redirected to their profile. A standard user can only view, edit, or delete their own profile.

### Administrator

After login, an administrator is redirected to the dashboard. Administrators can:

- View user totals and role totals.
- Create, edit, and delete users.
- Toggle user roles.
- Upload and monitor spreadsheet imports.

## 7. Useful Docker commands

```bash
# Show running services
docker compose ps

# Follow all application logs
docker compose logs -f web jobs

# Restart Rails and the worker
docker compose restart web jobs

# Run Rails console
docker compose exec web bin/rails console

# Run a Rails command
docker compose exec web bin/rails routes

# Check migration status
docker compose exec web bin/rails db:migrate:status

# Print the current Rails environment
docker compose exec web bin/rails runner 'puts Rails.env'
```

Rebuild after Dockerfile or application changes:

```bash
docker compose down
docker compose up --build --force-recreate
```

Do not use `-v` unless you want to delete all local database and upload data:

```bash
docker compose down -v
```

## 8. Tests and quality checks

The repository includes Minitest, request, job, channel, security, system, and React tests. CI runs the Ruby suite in parallel and checks frontend coverage.

The runtime Docker image is production-focused and excludes development/test-only gems. The complete quality pipeline runs in CI or in a development Ruby/Node environment:

```bash
bin/setup
RAILS_ENV=test bin/rails db:prepare
PARALLEL_WORKERS=4 PARALLEL_EXECUTOR=processes COVERAGE=true bin/rails test
bin/rails test:system
npm run test:ci
npm run check
npm run lint
npm run format:check
npm run build
bin/brakeman --no-pager
bin/bundler-audit check --update
```

The complete CI definition is in:

```text
config/ci.rb
```

## 9. Configuration

Local Docker defaults are defined in:

```text
docker-compose.yml
```

Important variables:

| Variable | Local default | Purpose |
| --- | --- | --- |
| `RAILS_ENV` | `production` | Production-shaped local Rails runtime. |
| `POSTGRES_PASSWORD` | `peoplehub` | Local PostgreSQL password. |
| `SEED_ADMIN_EMAIL` | `admin@example.com` | Initial administrator email. |
| `SEED_ADMIN_PASSWORD` | `PeopleHub!123456` | Initial administrator password. |
| `ACTIVE_STORAGE_SERVICE` | `local` | Stores avatars in the Docker volume. |
| `SMTP_ADDRESS` | `mailpit` | Local email capture service. |

Never commit real production secrets. Production uses environment variables or encrypted Rails credentials, S3-compatible storage, HTTPS, and a real SMTP provider.

## 10. Project layout

| Path | Responsibility |
| --- | --- |
| `app/models` | Persistence, validations, authentication, and invariants. |
| `app/controllers` | HTTP and authorization flows. |
| `app/services` | User mutations and spreadsheet parsing. |
| `app/jobs` | Background imports and broadcasts. |
| `app/frontend` | React/Inertia pages and components. |
| `public/user_import_template.csv` | Downloadable spreadsheet template. |
| `db/seeds.rb` | Initial administrator seed. |
| `test` | Unit, request, job, channel, security, and system tests. |
| `Dockerfile` | Multi-stage Ruby/Node production image. |
| `docker-compose.yml` | Complete local Docker environment. |
| `config/deploy.yml` | Kamal 2 deployment configuration. |

## 11. Official references

- [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Rails configuration and environments](https://guides.rubyonrails.org/configuring.html)
- [Rails Active Storage](https://guides.rubyonrails.org/active_storage_overview.html)
- [Rails command line and database tasks](https://guides.rubyonrails.org/command_line.html)
- [Inertia Rails](https://inertia-rails.dev/guide)
- [Solid Queue](https://github.com/rails/solid_queue)
- [Solid Cable](https://github.com/rails/solid_cable)
