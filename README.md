# Fullstack Developer Test — User Management App

A user management application built for Umanni's Modern Fullstack Developer Test:
role-based authentication, an admin dashboard with real-time counters, full user
CRUD, and asynchronous CSV/XLSX spreadsheet import with a live progress bar.

### AI Usage Disclosure

Per Umanni's AI Policy, this is an honest account of the AI assistance actually used:

- **Claude Code** (Anthropic, powered by Claude models — current session running
  **Claude Sonnet 5**) was used throughout the project for code generation,
  refactoring, test writing, and this documentation.
- **Aider** with **Claude 3.7 Sonnet** was tried very early on as an initial,
  exploratory test of the tool. It did not produce any code that remains in the
  current codebase — all application code was written via Claude Code.
- **Gemini** was used to help draft a visual/design redesign roadmap.

## Tech Stack

- **Ruby 4.0** / **Rails 8.1** (Ruby 4's ZJIT enabled in production, see
  [Architecture Decisions](#architecture-decisions))
- **Hotwire** (Turbo 8 + Stimulus) — no React/Inertia, see rationale below
- **Tailwind CSS v4**
- **SQLite** (multi-database: primary/cache/queue/cable, native WAL mode)
- **Solid Cache / Solid Queue / Solid Cable** — no Redis required
- **Pundit** for authorization
- **Rails 8 built-in authentication** (`bin/rails generate authentication`) — no Devise
- **RSpec** + FactoryBot + Faker + Shoulda Matchers + SimpleCov + Capybara/Playwright
  + `parallel_tests`
- **Propshaft** + importmap for asset management
- **Kamal 2** + **Thruster** for deployment, multi-stage **Docker** build

## Requirements

- Ruby 4.0+ (see `.ruby-version`)
- Node.js (only for Playwright's CLI and browser binaries used by system specs — CI
  uses Node 22; see [Setup](#setup) for the install order that matters)
- SQLite 3.8+
- Docker (optional, for containerized run/deploy)
- **libvips** (Required for ActiveStorage image processing)

> **⚠️ Important Note on Image Processing:** 
> Starting with Rails 7, ActiveStorage defaults to using the `vips` variant processor instead of `ImageMagick`. You must have the `libvips` system library installed on your machine to upload and process avatars successfully (e.g., `sudo apt-get install libvips` on Debian/Ubuntu or `brew install vips` on macOS). If this package is missing, ActiveStorage will fail to load the variant processor silently and throw a `NoMethodError (undefined method 'new' for nil)` when attempting to generate image thumbnails.

## Setup

```bash
bundle install
npm install                      # installs the exact Playwright CLI pinned in package.json
npx playwright install chromium  # downloads the Chromium binary into ~/.cache/ms-playwright
bin/rails db:prepare             # creates all 4 databases and loads the schema
bin/rails db:seed                # creates the bootstrap admin user (see below)
```

On Linux you may also need Chromium's OS-level libraries, which Playwright installs
with `sudo npx playwright install-deps chromium` (this is what CI does via
`playwright install --with-deps chromium`).

> **⚠️ Run `npm install` *before* `npx playwright install`.** The `playwright` Ruby
> gem drives a Node Playwright CLI whose version must match the gem's
> `Playwright::COMPATIBLE_PLAYWRIGHT_VERSION` (currently **1.62.1**, pinned exactly
> — no `^` — in `package.json`, so `npm install`/`npm update` can't drift off it).
> With no local `node_modules`, `npx` silently fetches the
> *latest* Playwright instead, which expects a different browser build number than
> the one on disk — so system specs fail with `Executable doesn't exist at
> ~/.cache/ms-playwright/chromium_headless_shell-<build>/...` even right after you
> ran `playwright install`. Installing the pinned CLI first keeps the CLI, the gem,
> and the downloaded browser on the same version. You can verify the two agree with:
>
> ```bash
> bundle exec ruby -e 'require "playwright"; puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION'
> node -e "console.log(require('./node_modules/playwright/package.json').version)"
> ```

## Seeding

Public registration always creates a `no_admin` user (enforced server-side in
`RegistrationsController`, ignoring any injected `role` param), so there is no way
to reach an admin account from the UI alone. `db/seeds.rb` creates two users,
idempotently, so the app is usable immediately after setup:

| Role     | Email               | Password      |
|----------|---------------------|----------------|
| Admin    | `admin@example.com` | `password123` |
| Regular  | `user@example.com`  | `password123` |

```bash
bin/rails db:seed
```

Change these default passwords before deploying anywhere reachable by others.

## Running in development

```bash
bin/dev   # runs `bin/rails server` + `bin/rails tailwindcss:watch` via Procfile.dev
```

Visit `http://localhost:3000`, sign in with the seeded admin (or register a new
regular user), and Solid Queue/Solid Cable both run in-process — no extra services to
start. Outgoing mail (password reset / "set your password" for imported users) is
logged to the Rails console (`ApplicationMailer#log_to_console_in_development`,
look for `[Mailer]` lines) and also written to `tmp/mails` — nothing opens
automatically, since a bulk spreadsheet import can send thousands of e-mails at
once.

## Running the test suite

```bash
bin/rails db:test:prepare               # after any new migration
bundle exec rspec                       # full suite, sequential
bundle exec rspec spec/path/to_spec.rb  # a single file
bundle exec parallel_rspec spec/        # parallel, same as CI

# System specs (Playwright) — needs the browser installed first, see Setup above.
# Set this if the Playwright CLI isn't otherwise resolvable:
PLAYWRIGHT_CLI_EXECUTABLE_PATH=./node_modules/.bin/playwright bundle exec rspec spec/system
```

Quality gates:

```bash
bundle exec rubocop
bundle exec brakeman -q --no-pager
bundle exec bundler-audit check
```

Current state: 0 failures, ≥90% SimpleCov line coverage (enforced via
`SimpleCov.minimum_coverage` — the suite itself fails if coverage regresses below
that bar), 0 RuboCop offenses, 0 Brakeman warnings, 0 bundler-audit vulnerabilities.

## Running with Docker

```bash
docker build -t fullstack_developer .
docker run -d -p 3000:80 \
  -e SECRET_KEY_BASE="$(openssl rand -hex 64)" \
  -e SOLID_QUEUE_IN_PUMA=true \
  --name fullstack_developer \
  fullstack_developer
```

**No secret to obtain.** This app stores no encrypted Rails credentials (nothing in
`app/`, `lib/`, or `config/` reads `Rails.application.credentials`), so it needs
`secret_key_base` and nothing else — any freshly generated value works, and a clone of
this repo can run the image without being handed a key. `SECRET_KEY_BASE` is read
before credentials are ever touched, so no `config/master.key` is involved. The one
thing the value affects is session and signed-cookie continuity: a new value on every
`docker run` signs everyone out across restarts, which is fine for evaluation but not
for a real deployment — see [Deploying with Kamal 2](#deploying-with-kamal-2). If you
prefer the standard Rails flow, `bin/rails credentials:edit` generates your own
`config/master.key` + `config/credentials.yml.enc` pair, and `-e RAILS_MASTER_KEY=...`
then works instead.

The image is a non-root, multi-stage build served by **Thruster** (zero-config
asset caching/compression/HTTP proxy) on port 80. `SOLID_QUEUE_IN_PUMA=true` runs
the Solid Queue supervisor inside the same Puma process, so no separate worker
container is needed for this single-server setup. Run `bin/rails db:seed` inside the
container (`docker exec -it fullstack_developer bin/rails db:seed`) to create the
bootstrap admin.

## Deploying with Kamal 2

`config/deploy.yml` is parsed as ERB before YAML, so both the target host and the
container registry are read from environment variables rather than hardcoded —
there is no real production server for this test, so a deploy attempted without
these sane, safe defaults fails fast instead of silently targeting an unrelated
machine:

```bash
KAMAL_WEB_HOST=<your server ip/host> \
KAMAL_REGISTRY_USERNAME=<your github username> \
KAMAL_REGISTRY_PASSWORD=<a GitHub PAT with write:packages> \
SECRET_KEY_BASE=<a stable 128-char hex value> \
bin/kamal deploy
```

`.kamal/secrets` reads `SECRET_KEY_BASE` from the deploying shell's environment and
`config/deploy.yml` declares it under `env.secret` — the two must name the same
secret or Kamal aborts. Unlike the throwaway value used for a local Docker run, this
one must stay **stable across deploys**: changing it invalidates every existing
session and signed cookie. Generate it once with `openssl rand -hex 64` and keep it in
a password manager or your CI's secret store. To use Rails credentials instead, swap
both references to `RAILS_MASTER_KEY` (the alternative is commented in
`.kamal/secrets`).

You can render the full config without contacting a server, which validates the ERB
and resolves the secrets:

```bash
SECRET_KEY_BASE=test KAMAL_REGISTRY_USERNAME=x KAMAL_REGISTRY_PASSWORD=y \
  KAMAL_WEB_HOST=198.51.100.10 bin/kamal config
```

## Environment Variables

| Variable                 | Used by                       | Purpose                                                              | Default                         |
|---------------------------|--------------------------------|-------------------------------------------------------------------------|----------------------------------|
| `SECRET_KEY_BASE`         | Rails, Kamal                  | Signs sessions and signed cookies in production                       | —  (required in production)     |
| `RAILS_MASTER_KEY`        | Rails credentials, Kamal      | Optional alternative to `SECRET_KEY_BASE`, only if you generate your own credentials via `bin/rails credentials:edit` | —  (unused by default)          |
| `RAILS_MAX_THREADS`       | Puma, `database.yml`          | Puma thread pool size / SQLite connection pool size                  | `3` (Puma) / `5` (DB pool)       |
| `PORT`                    | Puma                          | Server port                                                            | `3000`                          |
| `SOLID_QUEUE_IN_PUMA`     | `config/puma.rb`, Kamal       | Runs the Solid Queue supervisor inside the Puma process               | unset (off)                     |
| `JOB_CONCURRENCY`         | `config/queue.yml`            | Number of Solid Queue worker processes                               | `1`                              |
| `RAILS_LOG_LEVEL`         | `config/environments/production.rb` | Production log verbosity                                      | `info`                           |
| `KAMAL_WEB_HOST`          | `config/deploy.yml`           | Deploy target host/IP                                                  | `203.0.113.10` (RFC 5737, fails fast) |
| `KAMAL_REGISTRY_USERNAME` | `config/deploy.yml`           | GHCR username / image namespace                                       | `your-github-username`          |
| `KAMAL_REGISTRY_PASSWORD` | `.kamal/secrets`              | GHCR auth (GitHub PAT, `write:packages` scope)                        | —  (required to deploy)         |

## Architecture Decisions

- **Hotwire over React/Inertia** — chosen explicitly for this project to keep a
  classic-modern monolith: Turbo Streams over Solid Cable cover every real-time
  requirement (dashboard counters, import progress) without a client-side JS build
  or state-management layer, and Stimulus covers the handful of purely
  client-side interactions (mobile nav toggle, live password-confirmation
  validation).
- **SQLite in production, multi-database** — `primary`/`cache`/`queue`/`cable`, each
  its own SQLite file under `storage/`, mounted as a single Kamal volume. WAL mode
  is the Rails 8 SQLite adapter's default, so no extra configuration is needed for
  concurrent readers/writers. No Redis, Postgres, or MySQL to provision.
- **Rails 8 built-in authentication**, not Devise — generated via
  `bin/rails generate authentication`, then customized: the generator's
  `email_address` field was renamed to `email` (matching this project's
  requirements), and a `role` enum (`no_admin`/`admin`, default `no_admin`) was
  added. Public registration always forces `no_admin` server-side, even if a `role`
  param is injected in the request.
- **Pundit for authorization** — `ApplicationController#pundit_user` maps to
  `Current.user` (the app uses `Current.user` throughout, not the Devise-style
  `current_user`). `after_action :verify_authorized` is enforced globally, with a
  narrow `skip_after_action` only on the three pre-authentication controllers
  (sessions, passwords, registrations).
- **Spreadsheet import via a single gem (`roo`)** — reads both CSV and XLSX through
  the same API (`Roo::Spreadsheet.open`), avoiding a second gem
  (`roo-xlsx`/`caxlsx`) purely for one format. An admin can mark whether the file
  has a header row; either way, column mapping is purely **positional** (1st column
  = full name, 2nd = email) and a header's text is never used to map columns. Each
  row is validated and processed independently in a dedicated
  `SpreadsheetParser`/`SpreadsheetImportRowImporter` pair of services (the job
  itself only orchestrates: parse, loop, track progress, set final status). A bad
  row is recorded as a `SpreadsheetImportRowError` (row number + message + raw
  data) without aborting the rest of the import. Progress broadcasts are throttled
  to once every 10 rows rather than firing on every single row, to keep large
  imports from flooding Turbo Streams with broadcasts — the final state is always
  covered separately by the status transition at the end of the import, which
  already reflects the finished row count on its own. Imported users get an
  unusable random password and a "set your password" e-mail reusing the existing
  password-reset token mechanism, since they never chose one themselves.
- **Avatar via remote URL** (`app/services/avatar_fetcher.rb`) — fetched with
  `Net::HTTP` (never `URI.open`/`open-uri` on a user-supplied URL) behind an SSRF
  guard: resolves the host and rejects private/loopback/link-local IPs, limits
  redirects, validates `content_type` against an allowlist, and streams the body
  with a size cutoff enforced during download rather than after.
- **Ruby 4 ZJIT in production** — enabled via `RUBYOPT="--zjit"` in the Dockerfile.
  Rails 8.1 enables YJIT by default in production (`config.yjit = !Rails.env.local?`);
  since only one JIT can run per process, `config.yjit = false` is set explicitly in
  `config/environments/production.rb` so ZJIT wins cleanly instead of both JITs
  fighting for the slot and Ruby printing a boot-time conflict warning.
- **Solid Cache for dashboard counts** — `User.dashboard_counts` caches the
  dashboard's total/by-role numbers, written through by the same hook that already
  knew when they changed, rather than recomputing on every render.
- **Playwright over a lighter Capybara driver** — every real-time system spec
  (Turbo Stream/Action Cable delivery, multi-session dashboard updates) needs a
  real JS-executing, WebSocket-capable browser; a lighter driver like Cuprite would
  technically cover the same ground, but Playwright/Capybara is the combination
  this test's own brief names as the expected frontend-testing stack, so it was
  kept as-is rather than swapped for a marginally lighter alternative.

## Security

Covered by `spec/requests/security_spec.rb` and verified manually against a real
running server: parameterized queries via ActiveRecord (no raw SQL, immune to the
classic `' OR '1'='1` injection), ERB auto-escaping everywhere (no `html_safe`/`raw`/
`sanitize` in the codebase — untrusted data, including full names and spreadsheet
row error messages, is always rendered escaped), CSRF protection
(`protect_from_forgery with: :exception`, Rails 8.1's default) rejecting
state-changing requests without a valid authenticity token, rate-limited
authentication endpoints (sign-in, password reset, and registration), strong params
on every controller (no `params.permit!`), and an SSRF-hardened remote avatar
fetcher. `bundle exec brakeman` and `bundle exec bundler-audit check` are both
clean.

Untrusted external input (spreadsheet cell contents during import, remote avatar
URLs) is always treated as inert data, never as instructions to follow — the same
principle applies to any text sourced from outside the application's own code.

## Project Structure Highlights

- `app/models/user.rb` — role enum, avatar validations, dashboard-count broadcast
- `app/services/avatar_fetcher.rb` — SSRF-hardened remote avatar download
- `app/services/spreadsheet_parser.rb` / `spreadsheet_import_row_importer.rb` —
  spreadsheet parsing and per-row user creation, orchestrated by
  `app/jobs/spreadsheet_import_job.rb`
- `app/policies/` — Pundit authorization policies
- `spec/` — RSpec suite (models, requests, jobs, services, policies, system specs)
