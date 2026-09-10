### AI Usage Disclosure

Assisted by Muse Spark (opencode contributor agent `muse-spark-1.3-contributor`).

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

Prerequisites: Ruby 4.0.6 with Bundler, Node.js with npm, PostgreSQL running locally. Database credentials are read from the standard Rails credential and environment configuration; no secret values are printed here.

Install backend and frontend dependencies:

```sh
bundle install
```

```sh
npm ci
```

Create, migrate, and seed the database (this creates the admin account and sample users):

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

Run the app in development (starts Rails plus the Vite dev server):

```sh
bin/dev
```

Run the full quality pipeline (setup, lint, audits, test build, tests, coverage gate, profiling):

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

## Deployment

Deployment is configured with Kamal 2 in `config/deploy.yml`. The image is published to `ghcr.io` (`ghcr.io/umanni/fullstack-developer:latest`), traffic terminates through an SSL proxy for the app host, and the stack defines `web` and `job` roles plus a Postgres 16 accessory for production data.

Required secrets are injected at deploy time and are never committed to the repository:

```sh
kamal secret set RAILS_MASTER_KEY=<rails-master-key> DB_PASSWORD=<production-db-password>
```

The server and database hosts currently in `config/deploy.yml` are placeholder, operator-supplied values (`192.168.0.1` for the web and job hosts, `192.168.0.2` for the Postgres accessory host, proxy host `fullstack-developer.umanni.dev`). Replace each placeholder with the real production addresses before the first deploy, then run the standard Kamal flow:

```sh
bin/kamal setup
```

```sh
bin/kamal deploy
```

Useful post-deploy commands (defined as aliases in `config/deploy.yml`):

```sh
bin/kamal console
```

```sh
bin/kamal logs -r job
```

## Known limitations

- Production SSR Node rendering is configured but unproven end-to-end against a live production deploy.
- PII columns are not encrypted at rest; bcrypt covers passwords only.
- Deploy hosts in `config/deploy.yml` are operator-supplied placeholder addresses that must be replaced with real infrastructure values.
