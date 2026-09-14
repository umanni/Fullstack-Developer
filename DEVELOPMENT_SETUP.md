# Development Setup with Docker Compose

This guide explains how to build and run the Umanni Users app locally with Docker Compose, and what happens inside the containers when you do.

- [1. What runs](#1-what-runs)
- [2. Prerequisites](#2-prerequisites)
- [3. Configure `.env`](#3-configure-env)
- [4. Build the image](#4-build-the-image--docker-compose-build)
- [5. Start the stack](#5-start-the-stack--docker-compose-up)
- [6. How a request flows through the system](#6-how-a-request-flows-through-the-system)
- [7. Background jobs (Solid Queue)](#7-background-jobs-solid-queue)
- [8. Seed the database](#8-seed-the-database)
- [9. Day-to-day development workflow](#9-day-to-day-development-workflow)
- [10. Command reference](#10-command-reference)
- [11. Data and persistence](#11-data-and-persistence)
- [12. Troubleshooting](#12-troubleshooting)
- [13. Known gaps in the current setup](#13-known-gaps-in-the-current-setup)

---

## 1. What runs

[docker-compose.yml](docker-compose.yml) defines two services on a private bridge network called `umanni-test`:

| Service | Container name | Image | Purpose | Reachable from your machine |
|---|---|---|---|---|
| `db` | `umanni-pg` | `postgres:17` | Primary database, plus the Solid Queue, Solid Cable, and Solid Cache databases | No (only inside the network, port 5432) |
| `web` | `umanni-users` | Built from [Dockerfile](Dockerfile) | Rails 8.1 + Puma behind Thruster, with the Solid Queue worker running inside Puma | **Yes: http://localhost:3000** |

There is no Redis: cache, background jobs, and Action Cable all run on PostgreSQL through the Solid adapters. Containers find each other by container name, so Rails connects to Postgres at `DB_HOST=umanni-pg`.

---

## 2. Prerequisites

- **Docker Desktop** (or another engine) with **Compose v2**. This guide uses `docker compose ...`. The legacy `docker-compose ...` binary accepts the same commands.
- **The Rails master key.** Ask a teammate for it, or copy it from `config/master.key` if you already have one. You need it because:
  - `User#email_address` is encrypted with Active Record Encryption, and its keys live in `config/credentials.yml.enc`.
  - `config/master.key` is excluded from the image by [.dockerignore](.dockerignore), so the key has to come in through the `RAILS_MASTER_KEY` environment variable.
- Port **3000** free on your machine.

> Docker Desktop on macOS installs its CLI in `~/.docker/bin`. If your shell prints `docker: command not found`, add `export PATH="$HOME/.docker/bin:$PATH"` to your shell profile.

---

## 3. Configure `.env`

Compose automatically reads a `.env` file next to `docker-compose.yml` and substitutes its values into every `${VAR}` in the file. `.env` is ignored by git ([.gitignore](.gitignore)) and never copied into the image ([.dockerignore](.dockerignore)), so secrets stay on your machine.

Create `.env` in the project root:

```dotenv
RAILS_MASTER_KEY=<contents of config/master.key>
SECRET_KEY_BASE=<output of: bin/rails secret   (or: openssl rand -hex 64)>
RAILS_ENV=development
RACK_ENV=development
```

The `web` service gets the following environment. Some values are hardcoded in `docker-compose.yml`, so setting them in `.env` has **no effect**:

| Variable | Value / source | Used by |
|---|---|---|
| `RAILS_MASTER_KEY` | `.env` | Decrypting credentials, including the Active Record Encryption keys |
| `SECRET_KEY_BASE` | `.env` | Signing sessions and cookies |
| `RAILS_ENV`, `RACK_ENV` | `.env` (the image also defaults `RAILS_ENV=development`) | Rails environment selection |
| `DB_HOST` | hardcoded `umanni-pg` | [config/database.yml](config/database.yml) |
| `POSTGRES_USER` / `POSTGRES_PASSWORD` | hardcoded `umanni` / `secret` | [config/database.yml](config/database.yml) |
| `APP_ORIGIN` | hardcoded `http://localhost:3000` | Allowed Action Cable origins ([development.rb](config/environments/development.rb)). Boot fails without it. |
| `SOLID_QUEUE_IN_PUMA` | hardcoded `true` | Starts the Solid Queue worker inside Puma ([config/puma.rb](config/puma.rb)) |

Development stores uploads on local disk, so no AWS variables are needed.

---

## 4. Build the image — `docker compose build`

```bash
docker compose build          # builds the `web` image (db is pulled, not built)
```

The first build downloads Ruby, Node, and all gems and npm packages, so it takes several minutes. Later builds reuse cached layers and take about 15–20 seconds when only application code changed.

The resulting image is named `fullstack-developer-web:latest`. [Dockerfile](Dockerfile) is a **multi-stage** build:

```
┌──────────────── base ────────────────┐
│ ruby:4.0.6-slim                      │
│ + curl, libjemalloc2, libvips,       │
│   postgresql-client                  │
│ ENV RAILS_ENV=development            │
│     BUNDLE_WITHOUT=development:test  │
└───────────────┬──────────────────────┘
                │
     ┌──────────▼─────────── build ────────────────────────────────┐
     │ + build-essential, libpq-dev, git, Node 26.8.2              │
     │ 1. bundle install  (Gemfile / Gemfile.lock layer — cached)  │
     │ 2. npm ci          (package-lock.json layer — cached)       │
     │ 3. COPY . .        (application code)                       │
     │ 4. bootsnap precompile                                      │
     │ 5. bin/rails assets:precompile                              │
     │      → Vite build (React + Tailwind) into public/vite-dev/  │
     │      → Vite SSR build (Node server) into public/vite-ssr/   │
     │ 6. rm -rf node_modules                                      │
     └──────────┬──────────────────────────────────────────────────┘
                │ copy /usr/local/bundle, /rails and the node binary
     ┌──────────▼─────────── final ───────────┐
     │ base + gems + app + compiled assets    │
     │ + node, for the Inertia SSR server     │
     │ runs as non-root user `rails` (1000)   │
     │ ENTRYPOINT bin/docker-entrypoint       │
     │ CMD ./bin/thrust ./bin/rails server    │
     │ EXPOSE 80                              │
     └────────────────────────────────────────┘
```

Things to know about the build:

- **Layer order matters for speed.** Gems and npm packages are installed *before* `COPY . .`. Editing app code reuses those layers. Changing `Gemfile.lock` or `package-lock.json` triggers a full reinstall.
- **Frontend assets are compiled at build time.** Vite is the only asset pipeline: it bundles the React app and builds Tailwind through `@tailwindcss/vite`. Because `RAILS_ENV=development`, it writes to `public/vite-dev/` (see [config/vite.json](config/vite.json)). The same step runs the SSR build (`ssrBuildEnabled`), which bundles React and Inertia into a self-contained Node server, `public/vite-ssr/ssr.js`. `node_modules` is removed from the final image, but the `node` binary stays to run that server. At runtime, vite_ruby logs `Skipping vite build. Watched files have not changed since the last build`.
- **Development and test gems are not installed** (`BUNDLE_WITHOUT=development:test`). `web-console`, `rspec`, `rubocop`, `brakeman`, and `dotenv` are therefore **not** in the container. Run tests and linters on your host (or in CI), not in this image. `faker` is a top-level gem, so seeds do work.
- **Secrets are never baked in.** `.env*`, `config/master.key`, `spec/`, `.git/`, `node_modules/`, and `log/`/`tmp/` contents are all in [.dockerignore](.dockerignore).

Force a clean rebuild with no cache:

```bash
docker compose build --no-cache web
```

---

## 5. Start the stack — `docker compose up`

```bash
docker compose up -d          # start in the background
docker compose logs -f web    # follow the Rails/Thruster logs (Ctrl-C stops following, not the app)
```

Or run in the foreground (logs in your terminal, Ctrl-C stops everything):

```bash
docker compose up
```

Build and start in one step:

```bash
docker compose up -d --build
```

Then open **http://localhost:3000**. Health check: `curl http://localhost:3000/up` returns `200`.

### Startup sequence

```
docker compose up
│
├─ db (umanni-pg)
│   ├─ empty pg_data volume? → create user `umanni`, database `umanni_users_development`,
│   │                          run config/postgres/init.sql (first boot only)
│   └─ healthcheck: pg_isready every 5s ───────────────┐
│                                                      │ depends_on: service_healthy
└─ web (umanni-users)  ◄───────────────────────────────┘
    └─ bin/docker-entrypoint ./bin/thrust ./bin/rails server
        ├─ args end in "./bin/rails server" → ./bin/rails db:prepare
        │     creates any missing databases, loads schema or runs pending migrations for
        │     primary, queue, cache, and cable
        └─ exec ./bin/thrust ./bin/rails server
              ├─ Thruster listens on :80   (container) ← published as localhost:3000
              └─ Puma listens on 127.0.0.1:3000 (inside the container only)
                   ├─ SOLID_QUEUE_IN_PUMA=true → Solid Queue supervisor, dispatcher and worker
                   └─ inertia_ssr plugin → node public/vite-ssr/ssr.js on :13714 (not published)
```

Key points:

1. **`web` waits until Postgres reports healthy** (`depends_on: condition: service_healthy`). It won't start before the database accepts connections.
2. **Migrations run automatically on every boot.** [bin/docker-entrypoint](bin/docker-entrypoint) runs `db:prepare` whenever the command ends in `./bin/rails server`. On a fresh volume it creates and loads all four development databases. On an existing one it only applies pending migrations. Commands like `docker compose exec web ./bin/rails console` skip this step.
3. **The `3000:80` port mapping is intentional.** Thruster (an HTTP/2 proxy that handles gzip, asset caching, and X-Sendfile) listens on port 80 and forwards to Puma on port 3000 *inside* the container. Browser traffic always goes through Thruster.
4. **Background jobs start with the server.** Puma's `solid_queue` plugin forks the Solid Queue supervisor, so imports are processed without a separate container ([section 7](#7-background-jobs-solid-queue)).
5. During the first second or two you may see `Unable to proxy request ... connection refused`. Thruster starts before Puma finishes booting, and the message stops once Puma is listening.
6. **Pages arrive server-rendered.** Once Puma has booted, its `inertia_ssr` plugin starts the Node SSR server (log line `Inertia SSR: server ready`) and restarts it if it crashes. Rails sends each Inertia page to it and puts the returned HTML in the response, and React hydrates that HTML in the browser. If the SSR server is down, pages still work: they render in the browser instead. `INERTIA_SSR_ENABLED=false` turns SSR off.

### Databases

All four logical databases live in the single `umanni-pg` server:

| Rails role | Database | Purpose in development |
|---|---|---|
| `primary` | `umanni_users_development` | Users, sessions, imports, Active Storage records |
| `queue` | `umanni_users_development_queue` | Solid Queue job tables |
| `cable` | `umanni_users_development_cable` | Solid Cable pub/sub messages (real-time dashboard and import progress) |
| `cache` | `umanni_users_development_cache` | Created by `db:prepare`, but development uses `:memory_store` |

[config/postgres/init.sql](config/postgres/init.sql) also creates `umanni_users_production_{queue,cache,cable}`. That script is shared with the Kamal Postgres accessory. The production databases are unused in development and harmless.

---

## 6. How a request flows through the system

```
Browser ──http://localhost:3000──► Docker port map ──► Thruster :80 ──► Puma 127.0.0.1:3000 ──► Rails
                                                        (gzip, asset                             │
                                                         caching)                                ├─► Postgres primary (umanni-pg)
                                                                                                 │
Browser ──ws://localhost:3000/cable──────────────────────────────────────────► Action Cable ─────┤
                                                                                  │              │
                                                    polls every 0.1s ◄────────────┘              │
                                                    Postgres cable DB (Solid Cable)              │
                                                                                                 │
Admin uploads spreadsheet ──► ProcessImportJob.perform_later ──► Postgres queue DB ──► Solid Queue worker
                                                                                   (inside Puma)
```

- **Pages** are Rails controllers rendering Inertia.js responses. On a full page load, Rails first posts the page to the Inertia SSR server (`127.0.0.1:13714`, inside the container) and sends back its HTML, so content shows before any JavaScript runs. React components then come from the prebuilt bundle in `public/vite-dev/`, served by Thruster, and hydrate that HTML. Later navigation is client-side, as before.
- **Real-time updates** (dashboard counters, import progress) use Action Cable at `/cable` on the Solid Cable adapter. Solid Cable stores messages in the `cable` database and polls it.
- **Background work** (spreadsheet imports on the `imports` queue, debounced dashboard broadcasts on `default`) is enqueued into the `queue` database through Solid Queue and picked up by the worker running inside Puma.

---

## 7. Background jobs (Solid Queue)

`docker-compose.yml` sets `SOLID_QUEUE_IN_PUMA=true`, so [config/puma.rb](config/puma.rb) loads the `solid_queue` plugin. When Puma boots, it forks a Solid Queue supervisor with one dispatcher and one worker. The worker has 3 threads and listens on all queues (see [config/queue.yml](config/queue.yml)). The worker starts and stops together with the web server: nothing to run by hand.

Check that it registered:

```bash
docker compose exec db psql -U umanni -d umanni_users_development_queue \
  -c "select kind, hostname, pid from solid_queue_processes;"
```

You should see a `Supervisor(fork)`, a `Dispatcher` and a `Worker` row.

To run the worker in the foreground instead, for example to watch job logs in isolation, remove `SOLID_QUEUE_IN_PUMA` from `docker-compose.yml`, run `docker compose up -d`, and start it by hand:

```bash
docker compose exec web ./bin/jobs
```

In production, Kamal runs jobs in a dedicated `job` role instead ([config/deploy.yml](config/deploy.yml)).

---

## 8. Seed the database

```bash
docker compose exec web ./bin/rails db:seed
```

[db/seeds.rb](db/seeds.rb) creates:

- **Admin:** `admin@umanni.test` / `password123`. To choose the password, pass `-e SEED_ADMIN_PASSWORD=...` to `docker compose exec`. The variable isn't forwarded from `.env`.
- **25 regular members** with Faker names and pravatar avatars, password `password123`.

The admin is created only once, but **every run adds 25 more members**, because Faker generates new unique emails each time.

Reset everything (drop, recreate, load schema, seed):

```bash
docker compose exec web ./bin/rails db:reset
```

---

## 9. Day-to-day development workflow

**The source code is not mounted into the container.** `web` runs the snapshot of the code that was copied in at build time. Rails' code reloading is enabled, but it only sees files inside the image. Edits on your host do **not** show up until you rebuild.

The loop for picking up changes:

```bash
# edit code on your host, then:
docker compose up -d --build web      # rebuild the image (≈15–20s with cache) and recreate the container
docker compose logs -f web
```

`db` keeps running, and its data persists in a named volume. Pending migrations run automatically when the new `web` container boots, and the job worker restarts with Puma.

| You changed... | What to run |
|---|---|
| Ruby, views, React/TS components, CSS | `docker compose up -d --build web` |
| A new migration | `docker compose up -d --build web` (the entrypoint migrates on boot) |
| `Gemfile` / `package.json` | Update the lockfile on the host first (`bundle install` / `npm install`), then `docker compose up -d --build web` (slower: gem/npm layers rebuild) |
| `docker-compose.yml` environment | `docker compose up -d` (Compose recreates the containers that changed) |
| `.env` values | `docker compose up -d` |

### Hot reload (hybrid mode)

For fast feedback (Vite HMR, instant Ruby reloads, tests, linters), run the Rails processes on your host with `bin/dev`, and use Compose only for Postgres. [Procfile.dev](Procfile.dev) starts Puma, the Vite dev server, and a Solid Queue worker (`bin/jobs`). This mode isn't configured out of the box:

1. Publish the Postgres port. Add this to the `db` service:
   ```yaml
       ports:
         - "5432:5432"
   ```
2. `docker compose up -d db`
3. On your host (Ruby 4.0.6 and Node 26 installed (`nvm use` reads `.nvmrc`), after `bundle install && npm install`), export the variables Rails expects. `.env` is not loaded automatically outside Compose:
   ```bash
   export DB_HOST=localhost POSTGRES_USER=umanni POSTGRES_PASSWORD=secret \
          APP_ORIGIN=http://localhost:3000
   bin/dev
   ```

Don't run the hybrid `bin/dev` and the `web` container at the same time. Both want port 3000.

---

## 10. Command reference

| Task | Command |
|---|---|
| Build the image | `docker compose build` |
| Start everything (background) | `docker compose up -d` |
| Rebuild and restart the app | `docker compose up -d --build web` |
| Service status and health | `docker compose ps` |
| Follow app logs | `docker compose logs -f web` |
| Rails console | `docker compose exec web ./bin/rails console` |
| Shell in the app container | `docker compose exec web bash` |
| Run migrations manually | `docker compose exec web ./bin/rails db:migrate` |
| Seed | `docker compose exec web ./bin/rails db:seed` |
| Routes | `docker compose exec web ./bin/rails routes` |
| psql (primary DB) | `docker compose exec db psql -U umanni -d umanni_users_development` |
| Solid Queue processes | `docker compose exec db psql -U umanni -d umanni_users_development_queue -c "select kind from solid_queue_processes;"` |
| Stop (keep containers and data) | `docker compose stop` |
| Stop and remove containers (keep data) | `docker compose down` |
| **Wipe everything, including the database and uploads** | `docker compose down -v` ⚠️ irreversible |
| Clean image rebuild | `docker compose build --no-cache web` |

Commands run through `docker compose exec` execute as the non-root `rails` user (UID 1000) in `/rails`.

---

## 11. Data and persistence

| Data | Where it lives | Survives `down` / `up --build`? |
|---|---|---|
| Postgres (all four databases) | Named volume `fullstack-developer_pg_data` | ✅ Yes. Lost only with `down -v` |
| Uploaded avatars and import files (Active Storage, `:local` service) | Named volume `fullstack-developer_storage_data`, mounted at `/rails/storage` | ✅ Yes. Lost only with `down -v` |
| Logs | Container stdout (`docker compose logs`) and `/rails/log` | ❌ No |

`config/postgres/init.sql` runs **only when `pg_data` is empty**. Editing it has no effect on an existing database unless you wipe the volume.

---

## 12. Troubleshooting

**`web` exits immediately, or errors mention credentials or encryption.**
`RAILS_MASTER_KEY` is missing or wrong. Rails can't decrypt `config/credentials.yml.enc`, and so has no Active Record Encryption keys for `User#email_address`. Check `.env`, then `docker compose up -d`.

**`Bind for 0.0.0.0:3000 failed: port is already allocated`**
Something else is using port 3000, often a host `bin/dev`. Stop it, or change the mapping to `"3001:80"`. If you change the port, also update `APP_ORIGIN` to `http://localhost:3001`, or Action Cable will reject WebSocket connections.

**`Found orphan containers ([umanni-redis])`**
An older version of this stack ran Redis. It's no longer used. Remove the leftover container with `docker compose up -d --remove-orphans`, and the old volume with `docker volume rm fullstack-developer_redis_data`.

**`Conflict. The container name "/umanni-pg" is already in use`**
The containers have fixed names, so only one copy of this stack can exist per Docker engine. Remove the old one (`docker rm -f umanni-pg umanni-users`), or run `docker compose down` from the other checkout.

**Code changes don't appear.**
Expected: the code is baked into the image. Run `docker compose up -d --build web` ([section 9](#9-day-to-day-development-workflow)).

**Imports stuck at "pending".**
The job worker isn't running. Check `solid_queue_processes` ([section 7](#7-background-jobs-solid-queue)), make sure `SOLID_QUEUE_IN_PUMA=true` is still set on `web`, and look for Solid Queue errors in `docker compose logs web`.

**Real-time updates don't arrive (WebSocket fails).**
`APP_ORIGIN` must exactly match the URL in your browser, including scheme and port (`http://localhost:3000`). Using `127.0.0.1:3000` instead of `localhost:3000` fails the origin check.

**`ActiveRecord::PendingMigrationError` in the browser.**
Migrations normally run on boot. If you ran `db:rollback` or similar by hand, run `docker compose exec web ./bin/rails db:migrate`.

**`Unable to proxy request ... connection refused` in the logs right after start.**
Harmless: Thruster started before Puma. It stops once Puma prints `Listening on http://127.0.0.1:3000`.

**`No route matches [GET] "/.well-known/appspecific/com.chrome.devtools.json"`**
Harmless: Chrome DevTools probes for this file.

**Start completely fresh.**
```bash
docker compose down -v            # ⚠️ deletes the database and uploads volumes
docker compose build --no-cache
docker compose up -d
docker compose exec web ./bin/rails db:seed
```

---

## 13. Known gaps in the current setup

- **The image is built with `RAILS_ENV=development`.** [Dockerfile](Dockerfile) hardcodes `RAILS_ENV=development` for this Compose setup, and [config/deploy.yml](config/deploy.yml) doesn't override it. A Kamal deploy would boot in development mode unless `RAILS_ENV: production` is added to `env.clear` (see [KAMAL_DISCLOUSURE.md](KAMAL_DISCLOUSURE.md)).

### Not to be confused with: the Kamal local rehearsal

[.kamal/local/compose.yml](.kamal/local/compose.yml) is a **separate** Compose file. It starts a fake "production server" (SSH + Docker-in-Docker) for rehearsing `bin/kamal deploy -d local`, served on http://localhost:8080. It has nothing to do with the development stack described here. See the comments in [config/deploy.local.yml](config/deploy.local.yml).
