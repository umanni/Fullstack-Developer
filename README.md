### AI Usage Disclosure

I used OpenAI Codex with GPT-5.6 Sol (`gpt-5.6-sol`) while designing the architecture, implementing features, writing tests, and reviewing this submission. I remained responsible for the technical decisions, reviewed the generated changes, and validated the result with automated checks, a production-mode Docker build, and hands-on browser testing.

# Umanni Full Stack Challenge: User Management

[![CI](https://github.com/tilipim123/Fullstack-Developer/actions/workflows/ci.yml/badge.svg?branch=feature%2Fsenior-user-management)](https://github.com/tilipim123/Fullstack-Developer/actions/workflows/ci.yml)
[![CodeQL](https://github.com/tilipim123/Fullstack-Developer/actions/workflows/codeql.yml/badge.svg?branch=feature%2Fsenior-user-management)](https://github.com/tilipim123/Fullstack-Developer/actions/workflows/codeql.yml)

This is my implementation of Umanni's full stack challenge. I chose the Hotwire option and kept the application close to the Rails 8 defaults: authentication comes from the built-in generator, background work and live updates use Solid Queue and Solid Cable, and PostgreSQL stores both application and operational data. The result runs without Redis or a separate frontend service.

## What I built

- Visitors can register with a name, unique email, password, and uploaded or remote HTTPS avatar. Self-registration always creates a standard user.
- Standard users are redirected to their own profile and can only view, edit, or delete that account.
- Administrators are redirected to a live dashboard and can search, create, edit, delete, promote, and demote users.
- The final administrator is protected from concurrent demotion or deletion.
- CSV and XLSX imports run asynchronously, retain per-row outcomes, tolerate partial failure, and publish live progress.
- Dashboard totals update through Turbo Streams whenever users or roles change.
- Authentication uses the Rails 8 generator, secure signed cookies, session revocation, password recovery, and rate limiting.
- The UI is responsive, keyboard-accessible, and built with Hotwire, Stimulus, Propshaft, and Tailwind CSS.

## Technology

| Concern | Choice |
| --- | --- |
| Runtime | Ruby 4.0.6 with ZJIT in the production image |
| Framework | Rails 8.1.3.1 |
| Database | PostgreSQL 17 |
| Frontend | Turbo 8, Stimulus, Importmap, Propshaft, Tailwind CSS 4 |
| Background work | Solid Queue |
| Real-time updates | Solid Cable + Turbo Streams |
| Cache | Solid Cache |
| Uploads | Active Storage |
| Spreadsheet parsing | Roo (CSV and XLSX) |
| Tests | Minitest, Capybara, Selenium/Chromium, SimpleCov |
| Delivery | Multi-stage Docker, Thruster, Docker Compose, Kamal 2 |

## Why I kept it as a monolith

These use cases share the same users, permissions, transactions, and reporting data, so splitting them into services would add failure modes without creating a useful ownership or scaling boundary. I kept one deployable Rails application and separated responsibilities inside it: controllers handle HTTP orchestration, models protect persistence invariants, service objects own mutations, query objects compose reads, and jobs provide the asynchronous boundary.

```mermaid
flowchart LR
  Browser[Hotwire browser] --> Controllers[Rails controllers]
  Controllers --> Services[Domain services]
  Controllers --> Queries[Query objects]
  Services --> PostgreSQL[(PostgreSQL)]
  Queries --> PostgreSQL
  Controllers --> Queue[Solid Queue]
  Queue --> Jobs[Import and broadcast jobs]
  Jobs --> PostgreSQL
  Jobs --> Cable[Solid Cable]
  Cable --> Browser
  Controllers --> Storage[Active Storage]
```

The boundaries and design decisions are described in [docs/architecture.md](docs/architecture.md). Security controls are documented in [docs/security.md](docs/security.md), the browser acceptance inventory is in [docs/qa-inventory.md](docs/qa-inventory.md), and the completed validation evidence is in [docs/qa-report.md](docs/qa-report.md).

## Run with Docker

Docker is the recommended path because it pins Ruby, PostgreSQL, Chromium, and the native dependencies.

```bash
git clone https://github.com/tilipim123/Fullstack-Developer.git
cd Fullstack-Developer
git switch feature/senior-user-management
docker compose up --build -d
docker compose run --rm web bin/rails db:seed
```

Open [http://localhost:3000](http://localhost:3000). Compose starts:

- `database`: PostgreSQL 17 with a persistent volume and health check;
- `setup`: one-shot preparation of the application, cache, queue, and cable databases;
- `web`: non-root production Rails image behind Thruster on port 3000;
- `jobs`: a dedicated Solid Queue supervisor.

Demo credentials created by the idempotent seed:

| Role | Email | Password |
| --- | --- | --- |
| Administrator | `admin@example.com` | `SecurePass123!` |
| Standard user | `member@example.com` | `SecurePass123!` |

These credentials are for local evaluation only. Stop the stack with `docker compose down`.

## Local development

Prerequisites are Ruby 4.0.6, PostgreSQL 17, and Chromium/Chrome for system tests.

```bash
cp .env.example .env
set -a && source .env && set +a
bundle install
bin/setup
bin/dev
```

`bin/dev` starts Rails, the Tailwind watcher, and Solid Queue. Seed at any time with `bin/rails db:seed`; the operation is idempotent.

## Configuration

No real secret is committed. Environment variables configure the runtime, while Rails credentials may supply SMTP values in production.

| Variable | Purpose | Local default |
| --- | --- | --- |
| `DB_HOST`, `DB_PORT` | PostgreSQL endpoint | `127.0.0.1:5432` |
| `DB_USERNAME`, `DB_PASSWORD` | PostgreSQL credentials | `postgres` / `postgres` |
| `APP_HOST`, `APP_PROTOCOL` | URL generation, host authorization, and HTTPS policy | `localhost` / `http` |
| `SECRET_KEY_BASE` | Cookie/message encryption in production | set by Compose for local evaluation only |
| `SMTP_ADDRESS`, `SMTP_PORT` | Optional SMTP endpoint | file delivery when absent |
| `SMTP_USERNAME`, `SMTP_PASSWORD` | Optional SMTP credentials | none |
| `RAILS_MAX_THREADS` | Rails database/web concurrency | `5` |
| `JOB_CONCURRENCY` | Solid Queue worker processes | `1` |
| `DOCKER_SUBNET` | Override the isolated Compose network if it conflicts with a local VPN | `198.18.113.0/24` |

For encrypted SMTP configuration:

```yaml
smtp:
  address: smtp.example.com
  port: 587
  user_name: example
  password: secret
```

Edit it with `bin/rails credentials:edit`. Environment variables take precedence. Without SMTP, production-like local runs write mail to `storage/mails`, so background jobs remain testable without an external service.

## Spreadsheet imports

Download either template from the import screen or use:

- `public/user_import_template.csv`
- `public/user_import_template.xlsx`

Required columns are `full_name`, `email`, and `avatar_image_url`. Optional `role` accepts `admin`, `user`, `no-admin`, `true`, `false`, `1`, or `0`. Files are limited to 5 MB and 1,000 data rows.

An import persists its status and every row before broadcasting. Valid rows commit independently; invalid or duplicate rows are displayed with an actionable error and never overwrite an existing account. Retrying a partially processed job skips rows already marked successful, and a terminal import is a no-op. The upload must have a matching extension and content type; XLSX archives are also checked for entry count, expanded size, and bounded sheet rows before parsing. If an administrator or imported user is later deleted, the audit trail remains available with anonymized references.

## Tests and quality gates

Run the same complete gate used by CI:

```bash
docker compose --profile tools run --rm test bin/ci
```

Individual commands:

```bash
docker compose --profile tools run --rm test bin/rails test
docker compose --profile tools run --rm test bin/rails test:system
docker compose --profile tools run --rm test bin/rubocop
docker compose --profile tools run --rm test bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
docker compose --profile tools run --rm test bin/bundler-audit
docker compose --profile tools run --rm test bin/importmap audit
```

The model, service, query, job, and controller tests run in parallel and enforce at least 90% line and 80% branch coverage. System tests execute real user journeys in headless Chromium. CI also builds the production image, runs CodeQL, replants seeds, and rejects security or lint warnings.

The latest full local execution and interactive production-browser results are recorded in [docs/qa-report.md](docs/qa-report.md).

## Browser support

The interface uses progressively enhanced server-rendered HTML, standard form controls, Turbo, and small Stimulus controllers. Rails' modern-browser policy is enabled, so unsupported legacy browsers receive the framework's compatibility response. The repeatable browser suite and the interactive desktop/mobile review use Chromium; the layout avoids browser-specific APIs and keeps JavaScript non-essential for authorization and persistence.

## Security summary

- Built-in Rails authentication with bcrypt and 12-character minimum passwords.
- Signed, HTTP-only, same-site session cookies; secure cookies on HTTPS; session reset on login; all sessions revoked after password reset.
- Central role authorization, explicit privilege-change endpoint, and strong structural parameters.
- CSRF protection, strict Content Security Policy with per-response nonces, host authorization, safe redirect validation, and login/reset rate limits.
- Parameterized user search with escaped wildcard input and default Rails HTML escaping.
- Extension, content type, size, row-count, HTTPS, and embedded-credential validation for external inputs.
- Database unique indexes, foreign keys, check constraints, and deterministic row locks around the last-admin invariant.
- Sensitive parameters, including spreadsheet row payloads, are filtered from logs.

See [docs/security.md](docs/security.md) for the threat boundaries and production checklist.

## Deployment with Kamal

`config/deploy.yml` provides separate web/job roles, Thruster health checks, a PostgreSQL 17 accessory, persistent Active Storage, TLS termination, and registry configuration.

```bash
cp .kamal/secrets.example .kamal/secrets
export KAMAL_WEB_HOST=server.example.com
export APP_HOST=users.example.com
export KAMAL_IMAGE=your-org/umanni-users
export KAMAL_REGISTRY_USERNAME=your-github-user
bin/kamal config
bin/kamal setup
```

Load values in `.kamal/secrets` from environment variables or a password manager. On multi-host deployments, replace local Active Storage with an object-storage service; the included named volume is intentionally scoped to a single-host evaluation deployment.

## Trade-offs I made

- I chose a modular monolith because transactions and authorization matter more here than independent service scaling.
- I used PostgreSQL-backed queue, cache, and cable adapters to avoid adding Redis to a challenge of this size.
- Imported users receive expiring password-setup links; I did not introduce a shared or default password.
- Uploaded avatars are durable Active Storage records. I deliberately do not fetch remote avatars on the server; the browser requests them without a referrer and falls back to initials when an image is unavailable.
