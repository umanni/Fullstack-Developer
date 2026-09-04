# devops

One script per action, each a thin wrapper over `docker compose`. The shared
helpers — logging, guards, and the `compose` wrapper that resolves the compose
file and the env file — live in `common.sh`; source it, do not execute it.

Every script prints what it is doing and stops on the first failure.

## The application

```bash
devops/app/setup.sh              # from a clean checkout: .env, images, databases, seeds
devops/app/setup.sh --no-seed    # the same, without the demonstration accounts
devops/app/reset.sh              # throw the environment away, including the data volume
devops/app/start.sh              # start everything, in the background
devops/app/start.sh --attach     # start in the foreground, streaming logs
devops/app/stop.sh               # stop everything, keeping the data
devops/app/restart.sh            # restart every service
devops/app/restart.sh web        # restart one
devops/app/status.sh             # what is running, and whether it answers
devops/app/seed.sh               # run the seeds again
devops/app/logs.sh               # follow every service at once
```

## Rails

```bash
devops/rails/console.sh          # a Rails console in the running container
devops/rails/logs.sh             # follow the web logs
devops/rails/migrate.sh          # run migrations
devops/rails/test.sh             # the suite
devops/rails/test.sh spec/models/user_spec.rb
devops/rails/test-parallel.sh    # across four workers, each with its own databases
devops/rails/lint.sh             # RuboCop
devops/rails/security.sh         # Brakeman, bundler-audit, importmap audit
```

## Worker

```bash
devops/worker/logs.sh            # follow the Solid Queue logs
devops/worker/status.sh          # what the queue is doing
```

## PostgreSQL

```bash
devops/postgres/psql.sh          # an interactive session
devops/postgres/logs.sh          # follow the database logs
devops/postgres/dump.sh          # dump development to tmp/backups/
devops/postgres/dump.sh tmp/backups/before-the-migration.dump
```

## Everything at once

```bash
devops/tests/all.sh              # lint, security analysis and the suite
```

## The `bin/` shortcuts

`bin/` holds the handful of commands used often enough to deserve a shorter
name. They delegate here; the work is in this directory.

| shortcut | runs |
| --- | --- |
| `bin/setup` | `devops/app/setup.sh` |
| `bin/setup --reset` | `devops/app/reset.sh` |
| `bin/dev` | `devops/app/start.sh` |
| `bin/dev --down` | `devops/app/stop.sh` |
| `bin/dev --status` | `devops/app/status.sh` |
| `bin/test` | `devops/rails/test.sh` |
| `bin/test --parallel` | `devops/rails/test-parallel.sh` |
| `bin/test --live` | `devops/rails/test.sh` with Solid Cable in place of the test adapter |
| `bin/lint` | `devops/rails/lint.sh` |
| `bin/ci` | the whole pipeline, defined once in `config/ci.rb` |

## Environment

Every script reads `.env` (created by `devops/app/setup.sh` from
`.env.example`) through the `compose` wrapper, so there is one place where the
compose file and the env file are resolved:

```bash
COMPOSE_FILE_PATH=/path/to/docker-compose.yml devops/app/status.sh
ENV_FILE_PATH=/path/to/.env devops/app/start.sh
```
