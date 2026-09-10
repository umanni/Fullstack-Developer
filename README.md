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
export DATABASE_URL="postgres://<user>:<password>@localhost:5432/fullstack_developer_development"
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

Seeded login accounts (all seeded passwords are `Password123` unless changed after seeding):

- Admin: `admin@example.com / Password123`
- Sample users: `ada@example.com`, `alan@example.com`, `grace@example.com`, `margaret@example.com` (all `Password123`)

> **Note:** Passwords must be at least 8 characters and include an uppercase letter, a lowercase letter, and a digit.

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

Sessions expire after 30 days of inactivity. The `Session` model tracks `last_active_at`, which is touched on every authenticated request. Expired sessions are automatically destroyed on the next request, and a background job (`ExpireSessionsJob`) runs daily to clean up stale records.

Password complexity is enforced: minimum 8 characters with at least one uppercase letter, one lowercase letter, and one digit. Import jobs auto-generate compliant passwords when the provided value is weak or blank.

Admin actions (user creation, deletion, role toggling, import creation) are logged to an `audit_logs` table with the acting user, target record, metadata, IP address, and user agent. The audit trail persists even after the target user is deleted (foreign key uses `ON DELETE SET NULL`).

User and import lists are paginated (25 per page) via Kaminari, with prev/next navigation in the frontend.

## Testing

The full pipeline entry point is `bin/ci`, which runs environment setup, RuboCop, bundler-audit, Brakeman, a Vite production test build, the Minitest suite, a seed replant check, the ZJIT profiling script, and the SimpleCov coverage gate.

The Minitest suite runs in parallel with `bin/rails test` (114 runs) and covers models, controllers, jobs, channels, mailers, and integration flows, including admin CRUD, role toggling, CSV and XLSX imports with failed-row reporting, authentication redirects, and authorization boundaries. Coverage is enforced with a SimpleCov minimum of 90, and the suite currently reports 92%+.

System tests live in `test/system/` and run under Capybara with headless Chrome via Selenium, exercising login, registration, profile editing, and the admin dashboard from a real browser. Performance profiling uses `benchmark/zjit_profile.rb` to compare warm runs with Ruby 4 ZJIT enabled against the baseline interpreter.

## Run with Docker

The simplest way to run the whole app is Docker — no Ruby, Node, or PostgreSQL installation needed. The `compose.yml` at the project root builds the app image and starts it together with a PostgreSQL database.

Prerequisite: Docker with Compose (`docker compose version`).

```sh
export RAILS_MASTER_KEY="$(cat config/master.key)"
export SECRET_KEY_BASE="$(openssl rand -hex 64)"
docker compose up --build
```

Then open **http://localhost:3000** in your browser.

That's it. The first run builds the image (takes a few minutes); later runs are fast. The app runs in production mode behind the Thruster proxy, exactly like the deployed version.

Stop the app:

```sh
docker compose down
```

To wipe the database and start fresh:

```sh
docker compose down -v
```

Notes:

- `RAILS_MASTER_KEY` is the contents of `config/master.key`.
- `SECRET_KEY_BASE` is required because the image runs in production mode and the repository's credentials file does not ship a production `secret_key_base`. Generate one with `openssl rand -hex 64`.
- The four `*_DATABASE_URL` variables are already set in `compose.yml`; they exist because the production configuration uses separate databases for Solid Cache, Solid Queue, and Solid Cable. Rails creates them automatically on first boot.
- Prefer running without Docker? Follow the "Build / Seed / Run" section above and use `bin/dev` — the app also runs on http://localhost:3000.

### Run the quality pipeline (`bin/ci`) with Docker

The full quality pipeline (lint, security audits, tests, coverage gate, profiling) runs inside the app container against the compose database. With the app stack running:

```sh
docker compose run --rm \
  -v "$(pwd)/config/master.key:/rails/config/master.key" \
  web sh -c 'RAILS_ENV=test DATABASE_URL=postgres://fullstack_developer:fullstack_developer@db:5432/fullstack_developer_test bundle exec bin/ci'
```

What this does:

- `docker compose run` starts a one-off `web` container on the compose network, so it can reach the `db` service.
- The `-v` mount makes `config/master.key` available inside the container — `bin/ci` reads it directly and the file is not baked into the image.
- `RAILS_ENV=test` and `DATABASE_URL` point the suite at a test database on the compose Postgres; Rails creates it automatically on the first run.
- `bundle exec bin/ci` runs the same pipeline as on the host: setup, RuboCop, bundler-audit, Brakeman, Vite test build, the Minitest suite, seed replant, ZJIT profiling, and the SimpleCov gate.

The container is removed when the run finishes (`--rm`). The app stack itself is unaffected.

### Run commands inside the app container

With the app stack running (`docker compose up --build`), run any Rails or Ruby command inside the `web` container with `docker compose exec`. The running container already has the environment configured, so no extra flags are needed:

```sh
docker compose exec web bin/rails console
```

```sh
docker compose exec web bin/rails runner 'puts User.count'
```

```sh
docker compose exec web bin/rails routes
```

```sh
docker compose exec web bin/rubocop
```

```sh
docker compose exec web bin/rails db:migrate
```

Notes:

- `docker compose exec` runs in the already-running `web` container; `docker compose run` (used for `bin/ci` above) starts a separate one-off container instead.
- For interactive commands like `rails console`, use `docker compose exec` without `-T`. For piping input (e.g. `echo 'puts User.count' | docker compose exec -T web bin/rails console`), add `-T`.
- If you started the stack without exporting `RAILS_MASTER_KEY` and `SECRET_KEY_BASE` first, the container will have blank values; restart with the exports from the "Run with Docker" section.

### How Kamal relates to local development

Kamal 2 (`config/deploy.yml`) is the production deployment tool — it builds the same Dockerfile, pushes the image to a registry, and rolls it out to remote servers over SSH. Locally, you are not running Kamal; you are using Docker directly. The relationship:

- **Same image**: `docker compose up --build` and `bin/kamal deploy` both build from the same `Dockerfile`, so what you validate locally is what ships.
- **Same proxy**: the image's `CMD` runs `bin/thrust` (Thruster) in both local and Kamal runs.
- **Same database shape**: the compose `db` service mirrors the Postgres 16 accessory defined under `accessories:` in `config/deploy.yml`.
- **Different secrets handling**: locally you pass `RAILS_MASTER_KEY` and `SECRET_KEY_BASE` as environment variables; Kamal injects them from `.kamal/secrets` via `bin/kamal secret set`.

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
- Deploy hosts in `config/deploy.yml` are operator-supplied placeholder addresses that must be replaced with real infrastructure values.
