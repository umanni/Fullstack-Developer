### AI Usage Disclosure

Assisted by OpenCode with models: `Muse Spark 1.3`, `DeepSeek v4 Flash`, `MiMo V2.5`.

# Fullstack Developer — User Management App

A modern, responsive monolithic SPA for managing users. Admins get a live dashboard with user counts by role, full CRUD over users, role toggling, and asynchronous spreadsheet imports with live progress. Regular users manage only their own profile, and visitors can register as normal users.

## Stack

| Layer | Technology |
| --- | --- |
| Language | Ruby 4.0.6 |
| Framework | Rails 8.1.3.1 |
| Database | PostgreSQL |
| Frontend | React 19 + Inertia.js + Vite |
| Styling | Tailwind CSS |
| Real-time | Solid Cable |
| Background jobs | Solid Queue |
| Proxy | Thruster |
| Deployment | Kamal 2 |

## Build / Seed / Run

These instructions assume a clean machine with nothing pre-installed. Every tool below is listed with a way to obtain it; if you already have a tool, skip its step.

### 1. Install Ruby 4.0.6

The app requires Ruby 4.0.6 (see `.ruby-version`). Any installation method that gives you a `ruby` executable on your `PATH` works — a version manager is convenient but not required.

Using a version manager (recommended, e.g. rbenv):

```sh
# rbenv + ruby-build
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL
rbenv install 4.0.6
rbenv global 4.0.6
```

Using your operating system's package manager (e.g. on Debian/Ubuntu):

```sh
sudo apt-get update
sudo apt-get install -y ruby-full build-essential libpq-dev libyaml-dev
```

Verify Ruby is available:

```sh
ruby -v   # must print ruby 4.0.6
```

### 2. Install Bundler

Bundler is the Ruby dependency manager. Install it with:

```sh
gem install bundler
```

Verify:

```sh
bundle -v
```

### 3. Install Node.js and npm

The frontend is built with Vite and requires Node.js (npm ships with it). Install via nvm (recommended) or your system package manager:

```sh
# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
exec $SHELL
nvm install 22
nvm use 22
```

Or on Debian/Ubuntu:

```sh
sudo apt-get install -y nodejs npm
```

Verify:

```sh
node -v   # Node 18 or newer
npm -v
```

### 4. Install PostgreSQL

The app uses PostgreSQL as its database. Install it with your system package manager:

```sh
# Debian/Ubuntu
sudo apt-get install -y postgresql postgresql-client
sudo service postgresql start
```

```sh
# macOS (Homebrew)
brew install postgresql@16
brew services start postgresql@16
```

Verify the server is reachable:

```sh
psql --version
```

If your PostgreSQL instance requires a password for the default user, set the `DATABASE_URL` environment variable so Rails can connect, for example:

```sh
export DATABASE_URL="postgres://<user>:<password>@localhost:5433/fullstack_developer_development"
```

### 5. Install backend and frontend dependencies

From the project root:

```sh
bundle install
```

```sh
npm ci
```

If `bundle install` fails while compiling native extensions, install the system packages listed in step 1 (`build-essential`, `libpq-dev`, `libyaml-dev`) and retry.

### 6. Create, migrate, and seed the database

This creates the admin account and sample users:

```sh
bin/rails db:create db:migrate db:seed
```

The setup script is an equivalent shortcut that prepares dependencies and the database without starting the server:

```sh
bin/setup --skip-server
```

Seeded login accounts (all seeded passwords are `password123` unless changed after seeding):

- Admin: `admin@example.com / password123`
- Sample users: `ada@example.com`, `alan@example.com`, `grace@example.com`, `margaret@example.com`

Sample import files for exercising the admin spreadsheet import (25 data rows each, distinct datasets):

- `test/fixtures/files/sample_users.csv`
- `test/fixtures/files/sample_users.xlsx`

### 7. Run the app in development

Starts Rails plus the Vite dev server:

```sh
bin/dev
```

Then open http://localhost:3000 in your browser.

### 8. Run the full quality pipeline

Runs setup, lint, audits, test build, tests, coverage gate, and profiling:

```sh
bin/ci
```

## Architecture

This is a monolithic SPA served by Rails, with client pages implemented in React under `app/frontend/pages/` and bridged through Inertia.js with Vite as the asset bundler. Navigation between the admin dashboard, user list, profile, and auth screens is handled as Inertia visits, so the app behaves like a single-page application while all routing and authorization stay server-side in Rails controllers.

Live updates use Solid Cable with no Redis dependency. The admin dashboard subscribes to `DashboardChannel` for total user counts and per-role breakdowns, which refresh as users are created, updated, deleted, or have their role toggled. Spreadsheet imports stream progress over `UserImportChannel`, so the admin sees each import move from pending through processing to completed or failed without polling.

Spreadsheet processing runs in the background with Solid Queue. Uploading a CSV or XLSX file enqueues a `UserImportJob` that parses rows (CSV through the Ruby standard library, XLSX through rubyXL), creates users for valid rows, and records per-row failures for invalid ones. The admin import history shows status and row-level error detail for every run.

Authentication uses the built-in Rails 8 authentication generator, extended with role-based redirects: admins land on `/admin` after login and regular users land on `/profile`. Authorization is enforced server-side so regular users can only view, edit, and delete their own profile, while every admin-only route is rejected for non-admins. All controllers use strict `params.expect` for structural parameter validation, and forms pair client-side interactive feedback with backend model validations.

## Testing

The full pipeline entry point is `bin/ci`, which runs environment setup, RuboCop, bundler-audit, Brakeman, a Vite production test build, the Minitest suite, a seed replant check, the ZJIT profiling script, and the SimpleCov coverage gate.

The Minitest suite runs in parallel with `bin/rails test` (107 runs) and covers models, controllers, jobs, channels, mailers, and integration flows, including admin CRUD, role toggling, CSV and XLSX imports with failed-row reporting, authentication redirects, and authorization boundaries. Coverage is enforced with a SimpleCov minimum of 90, and the suite currently reports 100%.

System tests live in `test/system/` and run under Capybara with headless Chrome via Selenium, exercising login, registration, profile editing, and the admin dashboard from a real browser. Performance profiling uses `benchmark/zjit_profile.rb` to compare warm runs with Ruby 4 ZJIT enabled against the baseline interpreter.

## Development with Docker

You can run the whole development environment with Docker instead of installing Ruby, Node, and PostgreSQL on your machine. Three options are available, from lightest to heaviest.

### Option A: PostgreSQL only (recommended for day-to-day dev)

This runs just the database in a container; Rails and Vite still run on your machine with `bin/dev`. It is the fastest way to get a clean database without installing PostgreSQL locally.

Prerequisite: Docker with Compose (`docker compose version`).

```sh
docker compose up -d
```

This starts PostgreSQL 16 on `localhost:5433` with:

- user: `fullstack_developer`
- password: `fullstack_developer`
- database: `fullstack_developer_development`

Then point Rails at it and set up the database:

```sh
export DATABASE_URL="postgres://fullstack_developer:fullstack_developer@localhost:5433/fullstack_developer_development"
bin/rails db:create db:migrate db:seed
bin/dev
```

Stop the database container when done:

```sh
docker compose down
```

To wipe the database volume entirely (fresh start):

```sh
docker compose down -v
```

### Option B: The app image with Thruster (production-like)

This builds the multi-stage Dockerfile and runs the app exactly as production does — Puma behind the Thruster proxy (`bin/thrust`), which adds asset caching, compression, and X-Sendfile acceleration. Use this to validate the production image locally.

Prerequisite: Docker (`docker --version`), and a reachable PostgreSQL (either the compose container from Option A or any other instance).

Build the image:

```sh
docker build -t fullstack-developer:dev .
```

Run it, wiring the database, the Rails master key, and a secret key base:

```sh
docker run -d -p 80:80 \
  --add-host=host.docker.internal:host-gateway \
  -e RAILS_MASTER_KEY="$(cat config/master.key)" \
  -e SECRET_KEY_BASE="$(openssl rand -hex 64)" \
  -e DATABASE_URL="postgres://fullstack_developer:fullstack_developer@host.docker.internal:5433/fullstack_developer_development" \
  -e CACHE_DATABASE_URL="postgres://fullstack_developer:fullstack_developer@host.docker.internal:5433/fullstack_developer_cache" \
  -e QUEUE_DATABASE_URL="postgres://fullstack_developer:fullstack_developer@host.docker.internal:5433/fullstack_developer_queue" \
  -e CABLE_DATABASE_URL="postgres://fullstack_developer:fullstack_developer@host.docker.internal:5433/fullstack_developer_cable" \
  --name fullstack-developer \
  fullstack-developer:dev
```

Notes:

- `host.docker.internal` reaches the PostgreSQL container running on your host (Option A). On Linux, the `--add-host=host.docker.internal:host-gateway` flag (included above) is required.
- `SECRET_KEY_BASE` is required because the image runs in production mode and the repository's credentials file does not ship a production `secret_key_base`. Generate one with `openssl rand -hex 64`.
- The four `*_DATABASE_URL` variables are required because the production configuration uses separate databases for Solid Cache, Solid Queue, and Solid Cable. Point all four at the same PostgreSQL instance (the compose container from Option A); Rails creates the extra databases automatically on first boot.
- The container listens on port 80; open http://localhost in your browser.
- The image is built for production (`RAILS_ENV=production`), so it serves precompiled assets and does not run the Vite dev server.

Stop and remove the container:

```sh
docker stop fullstack-developer && docker rm fullstack-developer
```

### Option C: Full local stack with Compose

For a one-command local stack, extend `compose.yml` with a `web` service that builds the Dockerfile and depends on the `db` service. This is the closest local approximation of the Kamal deployment topology (web container + Postgres accessory).

```yaml
services:
  db:
    # ... as above ...
  web:
    build: .
    ports:
      - "80:80"
    environment:
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY}
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      DATABASE_URL: postgres://fullstack_developer:fullstack_developer@db:5432/fullstack_developer_development
      CACHE_DATABASE_URL: postgres://fullstack_developer:fullstack_developer@db:5432/fullstack_developer_cache
      QUEUE_DATABASE_URL: postgres://fullstack_developer:fullstack_developer@db:5432/fullstack_developer_queue
      CABLE_DATABASE_URL: postgres://fullstack_developer:fullstack_developer@db:5432/fullstack_developer_cable
    depends_on:
      db:
        condition: service_healthy
```

Then:

```sh
export RAILS_MASTER_KEY="$(cat config/master.key)"
export SECRET_KEY_BASE="$(openssl rand -hex 64)"
docker compose up -d --build
```

The `web` service needs the same four `*_DATABASE_URL` variables as Option B (Solid Cache/Queue/Cable use separate databases in production mode) and a `SECRET_KEY_BASE`. Inside the compose network, the `db` service is reached on its internal port `db:5432` — the host-side `5433` mapping does not apply between containers.

### How Kamal relates to local development

Kamal 2 (`config/deploy.yml`) is the production deployment tool — it builds the same Dockerfile, pushes the image to a registry, and rolls it out to remote servers over SSH. Locally, you are not running Kamal; you are using Docker directly (Options A–C). The relationship:

- **Same image**: `docker build` (Option B/C) and `bin/kamal deploy` both build from the same `Dockerfile`, so what you validate locally is what ships.
- **Same proxy**: the image's `CMD` runs `bin/thrust` (Thruster) in both local and Kamal runs.
- **Same database shape**: the compose `db` service mirrors the Postgres 16 accessory defined under `accessories:` in `config/deploy.yml`.
- **Different secrets handling**: locally you pass `RAILS_MASTER_KEY` and `DATABASE_URL` as environment variables; Kamal injects them from `.kamal/secrets` via `bin/kamal secret set`.

Deployment is configured with Kamal 2 in `config/deploy.yml`. The image is published to `ghcr.io` (`ghcr.io/umanni/fullstack-developer:latest`), traffic terminates through an SSL proxy for the app host, and the stack defines `web` and `job` roles plus a Postgres 16 accessory for production data.

### Prerequisites

- **Docker** installed and running on your machine (Kamal builds the image locally). Verify with `docker --version`.
- **SSH access** to the production server(s) from your machine (Kamal deploys over SSH). Verify with `ssh <user>@<server-host>`.
- **A container registry account** with push access to `ghcr.io` (or whichever registry you set in `config/deploy.yml`). Authenticate Docker to it:

```sh
docker login ghcr.io
```

- **Kamal** — it is a gem in this project's bundle, so no separate install is needed. Verify it is available:

```sh
bin/kamal version
```

### Configure the deployment

1. **Set the real server addresses.** Open `config/deploy.yml` and replace the placeholder values with your production infrastructure:
   - `DEPLOY_WEB_HOST` (default `192.168.0.1`) — the server that runs the web app.
   - `DEPLOY_JOB_HOST` (default `192.168.0.1`) — the server that runs background jobs.
   - `DEPLOY_DB_HOST` (default `192.168.0.2`) — the server that runs the Postgres accessory.
   - `proxy.host` (`fullstack-developer.umanni.dev`) — the public hostname that will serve the app over HTTPS.

2. **Set the registry credentials.** In `config/deploy.yml`, uncomment and fill in `registry.username` and `registry.password` (or point `registry.password` at a `KAMAL_REGISTRY_PASSWORD` secret). Use a personal access token rather than your account password when possible.

3. **Set the deploy secrets.** Kamal reads secrets from `.kamal/secrets` and injects them into the containers. Set the required values:

```sh
bin/kamal secret set RAILS_MASTER_KEY=<rails-master-key> DB_PASSWORD=<production-db-password>
```

   - `RAILS_MASTER_KEY` is the contents of `config/master.key` (or the production master key for your environment).
   - `DB_PASSWORD` is the password the Postgres accessory will use.

### Deploy

From the project root, with Docker running and SSH access in place:

```sh
bin/kamal setup
```

`setup` provisions the server (installs Docker on it if needed), starts the Postgres accessory, and boots the app for the first time. On subsequent releases:

```sh
bin/kamal deploy
```

`deploy` builds the image, pushes it to the registry, and rolls it out to the servers.

### Post-deploy commands

Useful commands (defined as aliases in `config/deploy.yml`):

```sh
bin/kamal console
```

```sh
bin/kamal logs -r job
```

### Troubleshooting

- **`registry/username is required`** — you skipped step 2; fill in the registry credentials in `config/deploy.yml`.
- **SSH connection refused** — confirm the server address in `config/deploy.yml` and that your SSH key is authorized on the server.
- **Container exits immediately** — check the logs with `bin/kamal logs`; the most common cause is a missing or wrong `RAILS_MASTER_KEY`.

## Known limitations

- Production SSR Node rendering is configured but unproven end-to-end against a live production deploy.
- PII columns are not encrypted at rest; bcrypt covers passwords only.
- Deploy hosts in `config/deploy.yml` are operator-supplied placeholder addresses that must be replaced with real infrastructure values.
