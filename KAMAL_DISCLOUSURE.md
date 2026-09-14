# Kamal Deployment Status

## Summary

I intended to finish the Kamal 2 deployment and run it against a real server, but it was **not completed**. The repository contains Kamal configuration that is close to what a real VPS deploy needs, but that configuration has **not been verified with an actual `kamal deploy`**.

For development, Kamal is not needed. Docker Compose is enough (see [Development](#development)).

## Why the deploy was not completed

- **No VPS available.** I don't have a VPS to deploy to at the moment.
- **The local rehearsal didn't fit on my machine.** I tried simulating a VPS locally with **Multipass** (an Ubuntu VM acting as the server). A VM plus Docker, the built images, and the Postgres accessory need a lot of SSD space. My Mac has a 256 GB SSD with only about 20 GB free, which wasn't enough, so I couldn't get Kamal running.

## What is in the repository

| File | Purpose |
|---|---|
| [config/deploy.yml](config/deploy.yml) | Production deploy config (close to final) |
| [.kamal/secrets](.kamal/secrets) | Maps secrets from the local environment and `config/master.key`. No secret values are committed. |
| [config/deploy.local.yml](config/deploy.local.yml) + [.kamal/local/](.kamal/local/) | Local rehearsal destination (`-d local`): an SSH + Docker-in-Docker container standing in for a server. Not verified. |
| [Dockerfile](Dockerfile) | Multi-stage image served through Thruster on port 80 |

What `config/deploy.yml` defines:

- **Roles:** `web` (Puma behind Thruster) and `job` (runs `bundle exec rake solid_queue:start` for background imports).
- **Proxy:** kamal-proxy with SSL (Let's Encrypt), `app_port: 80`, and a health check on `/up`.
- **Builder:** `amd64`, the typical VPS architecture.
- **Accessory:** `postgres:17`, bound to `127.0.0.1:5432`, with persistent data and [config/postgres/init.sql](config/postgres/init.sql) creating the queue, cache, and cable databases.
- **Environment:** `APP_ORIGIN`, `WEB_CONCURRENCY`, `RAILS_MAX_THREADS`, S3 storage for Active Storage, `DB_HOST` pointing to the Postgres accessory.
- **Secrets:** `RAILS_MASTER_KEY`, `POSTGRES_PASSWORD`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `KAMAL_REGISTRY_PASSWORD`.
- **Aliases:** `console`, `shell`, `logs`, `jobs`.

## Remaining steps for a real VPS

1. **Replace the placeholders** in `config/deploy.yml`:

   | Placeholder | Replace with |
   |---|---|
   | `192.168.0.1` (`web`, `job`, `postgres` hosts) | The VPS public IP |
   | `<your-registry-user>` (`image`, `registry.username`) | Container registry account (for example Docker Hub or GHCR) |
   | `users.example.com` (`proxy.host`, `APP_ORIGIN`) | The real domain |
   | `umanni-users-production` (`AWS_S3_BUCKET`) | The real S3 bucket |

2. **Set the Rails environment.** The Dockerfile sets `RAILS_ENV=development` by default, so add `RAILS_ENV: production` under `env.clear` in `config/deploy.yml`.
3. **Point DNS** for the domain (an A record) to the VPS IP. Let's Encrypt needs this to issue the SSL certificate.
4. **Provide the secrets** on the machine running Kamal:
   ```bash
   export KAMAL_REGISTRY_PASSWORD=...
   export POSTGRES_PASSWORD=...
   export AWS_ACCESS_KEY_ID=...
   export AWS_SECRET_ACCESS_KEY=...
   # RAILS_MASTER_KEY is read from config/master.key
   ```
5. **Deploy:**
   ```bash
   bin/kamal setup     # first time: installs Docker on the host, boots Postgres, deploys the app
   bin/kamal deploy    # later deploys
   bin/kamal logs      # follow logs (alias)
   ```

## Development

For development, you only need Docker Compose:

```bash
docker compose build
docker compose up
```

The app is then available at http://localhost:3000. The Solid Queue worker runs inside Puma, so spreadsheet imports work without any extra step. See [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md) for the full guide: environment variables, seeding, background jobs, and troubleshooting.
