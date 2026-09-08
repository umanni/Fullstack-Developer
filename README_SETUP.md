# Setup & Deployment Guide — mini Rails 8 IAM + InertiaJS

Complete guide to run this application **locally** and **online** (Fly.io, Heroku, AWS, and
Azure Cloud). The whole guide is in English.

The application is a Ruby 4.0.6 / Rails 8.0.5 monolith with a **React SPA integrated via
Inertia.js** (Vite), SQLite databases in **WAL mode**, and the **Solid trio** (Cache, Queue,
Cable) — which means **no Redis** is required anywhere.

---

## Table of contents

- [1. Stack snapshot](#1-stack-snapshot)
- [2. Environment variables reference](#2-environment-variables-reference)
- [3. Local development](#3-local-development)
  - [3.1 Prerequisites](#31-prerequisites)
  - [3.2 First-time setup](#32-first-time-setup)
  - [3.3 Running the dev server](#33-running-the-dev-server)
  - [3.4 Seeds / demo credentials](#34-seeds--demo-credentials)
  - [3.5 Tests, coverage and linters](#35-tests-coverage-and-linters)
  - [3.6 Docker (production image)](#36-docker-production-image)
  - [3.7 Troubleshooting](#37-troubleshooting)
- [4. General production notes](#4-general-production-notes)
- [5. Deploying online](#5-deploying-online)
  - [5.1 Kamal 2 (project's first-class deploy)](#51-kamal-2-projects-first-class-deploy)
  - [5.2 Fly.io](#52-flyio)
  - [5.3 Heroku](#53-heroku)
  - [5.4 AWS](#54-aws)
  - [5.5 Azure Cloud](#55-azure-cloud)
- [6. Postgres note: when to scale horizontally](#6-postgres-note-when-to-scale-horizontally)
- [7. AI usage disclosure](#7-ai-usage-disclosure)

---

## 1. Stack snapshot

| Component | Version / tech | Notes |
|---|---|---|
| Ruby | 4.0.6 | `.ruby-version` (`ruby-4.0.6`); RVM/rbenv on the host, `ruby:4.0.6-slim` in Docker |
| Rails | 8.0.5.1 | `Gemfile:5` |
| Frontend | React 19 + Tailwind CSS 4 + MobX | Built by Vite via `vite_rails`; entrypoints in `app/frontend/entrypoints` |
| Database | SQLite 3 (WAL mode) | One primary DB + cache/queue/cable DBs in `storage/` |
| Realtime / jobs | Solid Cable / Solid Queue / Solid Cache | No Redis |
| Auth | Rails 8 native auth (`bin/rails generate authentication`) + bcrypt | Sessions in cookies + CSRF |
| Deploy | Kamal 2 + Thruster | Multi-stage Dockerfile (`Dockerfile`) |
| Process manager (dev) | Foreman / Overmind / Hivemind | Used by `bin/dev` with `Procfile.dev` |

Dev process layout (`Procfile.dev`):

```procfile
vite: bin/vite dev   # Vite dev server on port 3036
web:  bin/rails s    # Puma on port 3000
jobs: bin/jobs       # Solid Queue worker
```

---

## 2. Environment variables reference

All variables are documented in `.env.example`. In **development/test** the file `.env` is
loaded by `dotenv-rails`. In **production** the same values are injected by the cloud
provider / orchestrator — there is no `.env` inside the container.

| Variable | Required | Purpose |
|---|---|---|
| `APP_HOST` | Yes (prod) | Public host; used for absolute URLs and Rails host authorization (`production.rb:99`) |
| `APP_PROTOCOL` | No | `http` or `https` (default `https` in prod) |
| `APP_PORT` | No | Optional port for mailer URLs (e.g., `3000`) |
| `MAIL_FROM` | Yes (prod) | Mailer sender; production **raises** if blank (`production.rb:68`) |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_AUTH`, `SMTP_STARTTLS_AUTO` | No | Optional SMTP for password-reset emails; delivery disabled without `SMTP_HOST` |
| `SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD` | No | Admin credentials for seeds (dev/test default `admin@iam.local` / `Password123!`) |
| `SEED_ALLOW_IN_PRODUCTION` | No | `true` only if you really want to seed production (default `false`, see `db/seeds.rb`) |
| `RAILS_MASTER_KEY` | Yes (prod) | Decrypts `config/credentials.yml.enc`; matches `config/master.key` locally |
| `RAILS_MAX_THREADS` | No | Puma/Active Record pool threads (default 3) |
| `RAILS_LOG_LEVEL` | No | Log level for production (default `info`) |
| `RAILS_SERVE_STATIC_FILES` | No | Set `true` when there is no CDN in front of the container |
| `SOLID_QUEUE_IN_PUMA` | No | `true` runs the Solid Queue supervisor inside Puma (single-server deploy) |
| `JOB_CONCURRENCY` | No | Solid Queue worker processes (default 1, see `config/queue.yml`) |
| `WEB_CONCURRENCY` | No | Puma worker processes (default 1) |
| `VITE_RUBY_SKIP_ASSETS_PRECOMPILE_EXTENSION` | No | Used by the Docker build to control asset precompile |

Kamal-only variables (read from `config/deploy.yml`, sourced from `.env` on the deploy host):

| Variable | Purpose |
|---|---|
| `DOCKER_IMAGE` | Container image name, e.g. `your-user/mini_rails8_iam_with_inertia_js` |
| `APP_SERVER_HOST` | IP/DNS of the server where Kamal deploys |
| `REGISTRY_USERNAME` | Container registry username |
| `KAMAL_REGISTRY_PASSWORD` | Container registry token/password (from `.kamal/secrets`) |

---

## 3. Local development

### 3.1 Prerequisites

Install on your machine:

| Tool | Version | Why |
|---|---|---|
| Ruby | 4.0.6 | Matches `.ruby-version` |
| Bundler | any recent | Ruby gems |
| Node.js + npm | 22+ | Vite build/tooling (the Docker build uses `node:22-slim`) |
| SQLite 3 | 3.x | System library for the `sqlite3` gem |
| Foreman / Overmind / Hivemind | optional | `bin/dev` picks the first installed; it auto-installs Foreman otherwise |
| Docker | optional | Only needed for the production image / containerized runs |

Ruby can be installed with RVM or rbenv:

```bash
# RVM
rvm install 4.0.6
rvm use 4.0.6

# rbenv
rbenv install 4.0.6
rbenv local 4.0.6
```

### 3.2 First-time setup

From the repository root:

```bash
# 1. Ruby gems
bundle install

# 2. Frontend packages
npm install

# 3. Environment file (adjust the values!)
cp .env.example .env

# 4. Create, migrate and seed the databases
bin/rails db:prepare
```

> `bin/setup` runs all of the above automatically (bundle + npm + `db:prepare` + cleanup)
> and then starts the dev server (`bin/dev`).

Seeding is idempotent in development (see `db/seeds.rb`) and safe to re-run:

```bash
bin/rails db:seed
```

### 3.3 Running the dev server

```bash
bin/dev
```

`bin/dev` starts (in order of preference) **Overmind**, **Hivemind**, or **Foreman**, and
launches the three `Procfile.dev` processes:

| Service | URL/port |
|---|---|
| Web (Puma) | http://localhost:3000 |
| Vite dev server | http://localhost:3036/vite-dev/ |
| Solid Queue worker | in-process (no port) |

Alternatively, run each process in its own terminal:

```bash
bin/vite dev
bin/rails s
bin/jobs
```

The app is a single Inertia SPA: Rails renders the page shell and Vite serves the React
assets; hot reload is active. Logs stream to the terminal prefixed by process name.

### 3.4 Seeds / demo credentials

After seeding, log in at http://localhost:3000 with:

| Role | Email | Password |
|---|---|---|
| Admin | `admin@iam.local` | `Password123!` |
| Regular user | `user@iam.local` | `Password123!` |

Admin is redirected to the **User Admin Dashboard** after login; a regular user goes to the
**Profile** page.

### 3.5 Tests, coverage and linters

Backend (Minitest; 138 tests, coverage gate 80% via SimpleCov):

```bash
bin/rails test
PARALLEL_WORKERS=4 bin/rails test   # faster; skips the exact 80% merge gate
bin/rails test:system                # if system tests are added
```

Frontend (Vitest + Testing Library):

```bash
npm run test:frontend
```

Static analysis / style / types:

```bash
bundle exec rubocop            # Ruby lint (omakase)
bin/brakeman                   # security static analysis
npm run lint                   # ESLint
npm run check                  # TypeScript (tsc)
npm run format:check           # Prettier
```

CI reference: `.github/workflows/codeql-analysis.yml` (GitHub Actions).

### 3.6 Docker (production image)

The `Dockerfile` is multi-stage (base → build-assets → build → final), Thruster/Kamal-ready,
non-root, and runs the Vite build in a separate Node stage so the runtime image keeps no
Node tooling:

```bash
docker build -t mini_rails8_iam_with_inertia_js .

# Run it (needs the master key to decrypt credentials)
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=<value from config/master.key> \
  --name mini_rails8_iam_with_inertia_js \
  mini_rails8_iam_with_inertia_js
```

The entrypoint runs `./bin/rails db:prepare` automatically on `./bin/rails server` start
(`bin/docker-entrypoint`), so a fresh volume gets its schema on boot.

### 3.7 Troubleshooting

| Symptom | Fix |
|---|---|
| `Error: Port 3036 is already in use` | An orphaned Vite server is holding the port. Kill it: `pkill -f "node_modules/.bin/vite"` (check with `ss -ltnp \| grep 3036`). |
| `bin/dev` says nothing / falls to `gem install foreman` | Overmind/Hivemind/Foreman are not installed; let it install Foreman or `gem install foreman` first. |
| Password reset emails never arrive | SMTP is not configured. Set `SMTP_HOST` (+ user/password). See `production.rb:72-86`. |
| `MAIL_FROM is required` at boot in prod | Production requires `MAIL_FROM` (fail-fast). Add it to your platform env vars. |
| Rate limit errors during tests | Expected safeguards; tests clear `Rails.cache` between examples (see `test/test_helper.rb`). |

---

## 4. General production notes

Whatever platform you choose, the same principles apply:

1. **Single writer.** SQLite supports one writer — keep a **single app instance running the
   web + jobs** (`SOLID_QUEUE_IN_PUMA=true`), exactly like `config/deploy.yml` does. Scale
   horizontally only after moving the DB layer to Postgres (see [section 6](#6-postgres-note-when-to-scale-horizontally)).
2. **Persistent storage.** SQLite files and Active Storage uploads live under `/rails/storage`
   (`storage/production*.sqlite3`). Every platform below must persist that directory.
   Local Active Storage service is already the production default (`active_storage.service = :local`).
3. **Required env in production** (the app fails fast without them):
   `RAILS_MASTER_KEY`, `APP_HOST`, `MAIL_FROM`. Set `APP_PROTOCOL=https` when SSL terminates
   upstream; `config.force_ssl = true` is on for production by default.
4. **Health check.** The stock endpoint `/up` is used by platforms and load balancers
   (status 200 when the app is healthy). It is excluded from host authorization.
5. **Secrets.** Never commit `config/master.key`. Get the key locally with
   `bin/rails credentials:show --help` or keep the generated `config/master.key` as the
   source for `RAILS_MASTER_KEY`.
6. **Port.** The container listens on **80** (`EXPOSE 80`, Thruster). Override `PORT` only
   if the platform requires it; Puma reads `PORT` (`config/puma.rb:31`).
7. **SMTP** is optional but recommended — without it, password-reset emails are not delivered.

Env checklist per platform (fill all `Yes` entries):

| Variable | Local | Fly.io | Heroku | AWS | Azure |
|---|---|---|---|---|---|
| `RAILS_MASTER_KEY` | Yes | Yes | Yes | Yes | Yes |
| `APP_HOST` | Yes | Yes | Yes | Yes | Yes |
| `MAIL_FROM` | Yes | Yes | Yes | Yes | Yes |
| `SMTP_*` | optional | optional | optional | optional | optional |
| `SOLID_QUEUE_IN_PUMA=true` | n/a | optional | optional | optional | optional |
| `RAILS_SERVE_STATIC_FILES=true` | n/a | optional | optional | optional | optional |

---

## 5. Deploying online

### 5.1 Kamal 2 (project's first-class deploy)

The repository ships a complete `config/deploy.yml` for Kamal 2 (deploying the Docker image
to any Linux server over SSH with Let's Encrypt SSL). This path works on **any VM** —
including AWS EC2, Azure VM, or a DigitalOcean/misc droplet.

On your deploy host (local machine or CI), with the image already pushed:

```bash
# 1. Fill the Kamal vars (they are read by config/deploy.yml via ERB)
cat >> .env <<'EOF'
DOCKER_IMAGE=<your-user>/mini_rails8_iam_with_inertia_js
APP_SERVER_HOST=<server-ip-or-dns>
APP_HOST=<your-public-domain>
REGISTRY_USERNAME=<registry-user>
EOF
# 2. Provide the registry password for the secret holder
mkdir -p .kamal && touch .kamal/secrets
# add: KAMAL_REGISTRY_PASSWORD=<token>  (never commit .kamal)

# 3. Provision the server (installs Docker, creates the volumes, bootstraps Traefik)
source .env && bin/kamal setup

# 4. Build + push + deploy (env is already coalesced)
source .env && bin/kamal deploy
```

Useful aliases:

```bash
bin/kamal logs        # tail app logs
bin/kamal console     # rails console on the server
bin/kamal app exec --interactive --reuse "bin/rails dbconsole"
```

Kamal mounts the persistent volume `mini_rails8_iam_with_inertia_js_storage:/rails/storage`
(`deploy.yml:69`) and injects `RAILS_MASTER_KEY` as a secret. `APP_HOST` also configures the
Traefik SSL proxy host.

### 5.2 Fly.io

Fly.io runs the app as a **single Machine** with a **persistent volume** — the simplest fit
for SQLite.

```bash
# 1. Authenticate
fly auth login

# 2. Launch (answers questions, creates fly.toml / Dockerfile)
fly launch --no-deploy

# 3. Create and attach a persistent volume for /rails/storage
fly volumes create mini_rails8_iam_with_inertia_js_storage --size 20 --region <your-region>
```

Add to `fly.toml`:

```toml
app = "<your-app>"
primary_region = "<your-region>"

[build]
  dockerfile = "Dockerfile"

[mounts]
  source = "mini_rails8_iam_with_inertia_js_storage"
  destination = "/rails/storage"

[env]
  APP_HOST = "https://<your-app>.fly.dev"
  APP_PROTOCOL = "https"
  MAIL_FROM = "no-reply@<your-app>.fly.dev"
  SOLID_QUEUE_IN_PUMA = "true"

[http_service]
  internal_port = 80
  force_https = true
  auto_stop_machines = true

  [[http_service.health_checks]]
    path = "/up"
    interval = "30s"
    timeout = "5s"
    grace_period = "10s"
```

Push secrets and deploy:

```bash
fly secrets set RAILS_MASTER_KEY=<value from config/master.key>
fly deploy
```

Because the app is a **single-machine** deployment, keep the machine count at 1 (Fly's
default). If you add machines, move to Postgres first (`fly postgres create` + attach, see
[section 6](#6-postgres-note-when-to-scale-horizontally)).

### 5.3 Heroku

Heroku's filesystem is **ephemeral** — a SQLite database written to a dyno dies on every
deploy/restart. Two options:

**Option A — quick SQLite demo (data NOT durable).** Fine for evaluation only.

**Option B — durable (recommended).** Attach the managed **Postgres** add-on and switch the
production database, then deploy the container. This keeps data durable and lets you scale
multiple dynos.

```bash
# 1. Create the app and authenticate to Heroku Container Registry
heroku create <your-app>
heroku container:login

# 2. Add Postgres
heroku addons:create heroku-postgresql:mini --app <your-app>
heroku config:get DATABASE_URL --app <your-app>

# 3. Databases: switch production to Postgres (edit config/database.yml)
#    production.primary.adapter = postgresql, url = ENV["DATABASE_URL"]
#    (Optionally keep cache/queue/cable on sqlite or move them too — see section 6)

# 4. Set the env vars (RAILS_MASTER_KEY from your local config/master.key)
heroku config:set RAILS_MASTER_KEY=<key> APP_HOST=<your-app>.herokuapp.com \
  APP_PROTOCOL=https MAIL_FROM=no-reply@<your-app>.herokuapp.com \
  SOLID_QUEUE_IN_PUMA=true RAILS_SERVE_STATIC_FILES=true

# 5. Build and push the Docker image
heroku container:push web --app <your-app>

# 6. Run migrations, then release
heroku run bin/rails db:prepare --app <your-app>
heroku container:release web --app <your-app>
```

`<your-app>.herokuapp.com` gives HTTPS/SSL out of the box.

### 5.4 AWS

The cleanest options are **(1) EC2 + Kamal** (exactly what `config/deploy.yml` targets) or
**(2) Amazon ECS** with a single task + EFS. Both give durable disks.

**Option A — EC2 + Kamal 2 (recommended for this repo):**

1. Launch an EC2 instance (Ubuntu 24.04 or Amazon Linux 2023), size `t3.small`+.
   - Storage: default EBS root of 20 GB is enough (Docker named volumes live on it).
   - Security group: allow **22** (SSH), **80** and **443** (HTTPS via Thruster/Traefik).
2. SSH in and install Docker:

   ```bash
   sudo apt-get update && sudo apt-get install -y ca-certificates curl
   curl -fsSL https://get.docker.com | sudo sh
   sudo usermod -aG docker $USER
   ```

3. From your local machine, fill `.env` and deploy:

   ```bash
   cat >> .env <<'EOF'
   DOCKER_IMAGE=<your-user>/mini_rails8_iam_with_inertia_js
   APP_SERVER_HOST=<ec2-public-ip-or-dns>
   APP_HOST=<your-domain.com>
   REGISTRY_USERNAME=<registry-user>
   EOF
   mkdir -p .kamal && touch .kamal/secrets   # add KAMAL_REGISTRY_PASSWORD=<token>

   source .env && bin/kamal setup
   source .env && bin/kamal deploy
   ```

4. Point a DNS A record (`your-domain.com`) at the EC2 public IP and open a Let's Encrypt
   path for the domain — Kamal/Traefik provisions the certificate automatically on deploy.
5. The EBS-backed named volume `mini_rails8_iam_with_inertia_js_storage` persists
   SQLite + uploads across deploys. Back it up (EBS snapshots) or add EFS for cross-zone
   durability.

**Option B — Amazon ECS (Fargate single task + EFS):**

1. Create an EFS file system and mount target (same VPC/subnet as the task).
2. Register a task from your image (ECR), CPU 0.5 vCPU / 1 GB, port mapping **80**.
3. Add a `mountPoints`/`volumes` pair mounting the EFS at `/rails/storage`
   (EFS mount path like `/rails-storage`), and set the container's `User` to 1000.
4. Set env vars `RAILS_MASTER_KEY`, `APP_HOST`, `MAIL_FROM`, `SOLID_QUEUE_IN_PUMA=true`.
5. Health check: `/up` on port 80. Use an Application Load Balancer for HTTPS/SSL.

> Remember: SQLite = one writer. On ECS keep `Desired count = 1`, or move the primary DB to
> RDS Postgres to scale.

### 5.5 Azure Cloud

Azure options: **App Service** (managed PaaS), **Container Apps** (with an Azure Files share),
or a **Linux VM + Kamal** (identical to the AWS EC2 path in 5.4).

**Option A — Azure App Service (Docker container):**

App Service persistent storage is mounted at `/home`. Symlink `/rails/storage → /home/storage`.

```bash
az login

az group create --name <rg> --location brazilsouth
az acr create     --name <acrname> --resource-group <rg> --sku Basic --admin-enabled true  # optional

# Build & push (or push the Kamal-built image) then create the plan + web app
az appservice plan create --name <plan> --resource-group <rg> --is-linux --sku B1
az webapp create \
  --resource-group <rg> --plan <plan> --name <app> \
  --deployment-container-image-name <acrname>.azurecr.io/mini_rails8_iam_with_inertia_js:latest \
  --startup-file "sh -c 'mkdir -p /home/storage && ln -sfn /home/storage /rails/storage && exec ./bin/thrust ./bin/rails server'"
```

Enable persistent `/home` storage and set config/env:

```bash
az webapp config appsettings set \
  --resource-group <rg> --name <app> \
  --settings \
    WEBSITES_ENABLE_APP_SERVICE_STORAGE=1 \
    RAILS_MASTER_KEY=<key> \
    APP_HOST=https://<app>.azurewebsites.net \
    APP_PROTOCOL=https \
    MAIL_FROM=no-reply@<app>.azurewebsites.net \
    SOLID_QUEUE_IN_PUMA=true RAILS_SERVE_STATIC_FILES=true
```

`<app>.azurewebsites.net` provides HTTPS automatically; health check path `/up` can be set
in the portal under "Health checks".

**Option B — Azure Container Apps (Azure Files volume):**

```bash
az storage account create --name <storage> --resource-group <rg> --sku Standard_LRS
az storage share create --account-name <storage> --name <share> --quota 20

az containerapp env create --name <cae> --resource-group <rg> --location brazilsouth
az containerapp create \
  --resource-group <rg> --name <app> --environment <cae> \
  --image <registry>/mini_rails8_iam_with_inertia_js:latest \
  --target-port 80 \
  --volume storage-name=<shareingress> mount-path=/rails/storage \
  --secrets RAILS_MASTER_KEY=<key> \
  --env-vars APP_HOST=https://<app>.<region>.azurecontainerapps.io \
             APP_PROTOCOL=https MAIL_FROM=no-reply@<app>.<region>.azurecontainerapps.io \
             SOLID_QUEUE_IN_PUMA=true RAILS_SERVE_STATIC_FILES=true \
  --scale --min-replicas 1 --max-replicas 1
```

Keep min/max replicas at **1** for SQLite (single writer). Set the probe path to `/up`.

**Option C — Azure Linux VM + Kamal:** follow the AWS EC2 + Kamal instructions (section 5.4,
Option A) — the `config/deploy.yml` workflow is identical on any Linux box.

---

## 6. Postgres note: when to scale horizontally

SQLite comfortably serves this app in production on a **single persistent instance**.
To run **multiple web replicas** (HA, rolling zero-downtime) you must move the write path to a
network database — the spec explicitly allows PostgreSQL/MySQL.

Migration sketch:

```yaml
# config/database.yml (production)
production:
  primary:
    adapter: postgresql
    url: <%= ENV["DATABASE_URL"] %>
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  # keep cache/queue/cable on SQLite only if they stay single-node:
  cache:  { <<: *default, database: storage/production_cache.sqlite3, migrations_paths: db/cache_migrate }
  queue:  { <<: *default, database: storage/production_queue.sqlite3, migrations_paths: db/queue_migrate }
  cable:  { <<: *default, database: storage/production_cable.sqlite3, migrations_paths: db/cable_migrate }
```

- **Fly.io:** `fly postgres create` + `fly secrets set DATABASE_URL=<url>`.
- **Heroku:** `heroku addons:create heroku-postgresql:mini` (DATABASE_URL is auto-injected).
- **AWS:** RDS PostgreSQL, pass the URL via env / Kamal secret.
- **Azure:** Azure Database for PostgreSQL Flexible Server.

Active Storage uploads should also move to object storage in a multi-node setup
(AWS S3 / GCS / Azure Storage — templates are already commented out in `config/storage.yml`).

---

## 7. AI usage disclosure

This project was developed with the assistance of the AI coding tool **OpenCode**, using the
**Big Pickle** model for code generation, refactoring, testing and documentation.