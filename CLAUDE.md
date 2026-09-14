# Umanni user management

## Stack

- Ruby 4.0.6 (`.ruby-version`), Rails 8.1.3.1, Bundler 4.0.16.
- SQLite 3 via `sqlite3` 2.9.6. Solid Cache 1.0.10, Solid Queue 1.7.0, Solid Cable 4.0.2. No Redis anywhere.
- Propshaft, importmap-rails, Turbo, Stimulus, tailwindcss-rails 4.6.0 (Tailwind v4). Puma 8, Thruster in production.
- Minitest 6, Capybara + selenium-webdriver (headless Chrome), SimpleCov 1.2.0.
- RuboCop 1.90 with rubocop-rails-omakase, rubocop-minitest, rubocop-performance. Brakeman and bundler-audit in CI.

## Architecture

- Authentication is the Rails 8 generator output (`bin/rails generate authentication`), committed unmodified on its
  own and customised afterwards: signed `session_id` cookie, one `Session` row per browser, bcrypt digest,
  token-based password reset. `app/controllers/concerns/authentication.rb`, `Current.session`/`Current.user`.
- `User` has `full_name`, `email`, `password_digest`, `role`. `role` is a string-backed enum (`user`, `admin`) with
  `validate: true` and a database check constraint `users_role_check`.
- `email` uses `encrypts :email, deterministic: true`, so the unique index compares ciphertext and `authenticate_by`
  works, but `LIKE` on email is impossible. Dev/test keys live in `config/environments/{development,test}.rb` on
  purpose; production takes them from credentials (Rails default, nothing set in `production.rb`).
- At least one admin must always exist. Model validation plus `before_destroy`, because three routes can break it:
  role toggle, admin edit form, profile deletion.
- `Admin::BaseController` runs `require_admin`; every admin controller inherits from it. Admin routes:
  `admin/dashboard` (live counters), `admin/users` (all but show), `admin/users/:user_id/role` (update),
  `admin/spreadsheet_imports` (index, new, create, show).
- `Admin::Users::RolesController#update` toggles the role and answers with a Turbo Stream that replaces the row
  (`dom_id(user)`) and `#flash`. An admin cannot change their own role or delete themselves.
- Landing page after sign-in and at `/`: admins go to `admin_dashboard_url`, everyone else to `profile_url`
  (`ApplicationController#home_url_for`, reused by `HomeController`).
- Avatar is `has_one_attached :avatar_image` (Active Storage, Disk service). PNG/JPEG/WebP only, 2 MB cap, validated
  in the model. No variants; images are served at upload size and constrained by CSS.
- `Pagination` (`app/models/pagination.rb`) is a PORO: offset-based, fetches `per_page + 1` rows, no COUNT.
- `SpreadsheetImport` + `SpreadsheetImport::RowReader` + `SpreadsheetImportJob` (`ActiveJob::Continuable`) handle the
  .csv/.xlsx import. The job suppresses `User`'s debounced dashboard broadcast and paces refreshes itself.
- `resource :profile` routes `show edit update destroy`, all implemented. No id in the route, so `ProfilesController`
  reads `Current.user` and never a parameter.
- Tailwind component layer in `app/assets/tailwind/application.css`: `card`, `field-*`, `btn-*`, `badge-*`. Tailwind v4
  will not `@apply` one component class inside another, hence the selector lists.

## Database topology

- `config/database.yml`: development and production each have four SQLite databases, `primary`, `cache`, `queue`,
  `cable`, under `storage/`. Test is a single database (`storage/test.sqlite3`).
- Pragmas are explicit: `journal_mode: wal`, `synchronous: normal`, `foreign_keys: true`, `mmap_size`,
  `journal_size_limit`, `cache_size`.
- `config/cache.yml` and `config/cable.yml` name their database in development and production; `cable.yml` uses
  `async` in test. `test/config/solid_stack_test.rb` asserts the development and production halves stay true.
- Schema files: `db/schema.rb`, `db/cache_schema.rb`, `db/queue_schema.rb`, `db/cable_schema.rb`.

## Running it

- Docker: `docker compose up` builds `Dockerfile.dev`, runs `bin/rails db:prepare && bin/dev`, serves on host port
  3200 (`WEB_PORT=xxxx docker compose up` to change). Health check hits `/up`.
- Local: `bin/setup` (bundle, `db:prepare`, then `bin/dev`), or `bin/dev` alone. `bin/dev` runs foreman over
  `Procfile.dev`: `web`, `css` (Tailwind watcher), `jobs` (`bin/jobs`, Solid Queue). Default port 3000.
- Seeds (`bin/rails db:seed`) are idempotent, create 32 users, and refuse to run outside development and test —
  `db:prepare` seeds a freshly created database, and a production deploy must not come up with demo logins in it.
  Demo logins, password `secret-password`: `admin@umanni.test` (admin), `user@umanni.test` (user).
- Fixtures use `grace@umanni.test` (admin) and `ada@umanni.test` (user), same password.
- Development mail goes to SMTP on port 1025, host `SMTP_HOST` (default `localhost`, `mail` under Docker).
  Production reads a different variable, `SMTP_ADDRESS`, and raises on delivery errors instead of swallowing them.
  `docker compose --profile mail up` starts Mailpit on :8025. With nothing listening there delivery fails
  silently in development (`raise_delivery_errors = false`). Preview at `/rails/mailers`.
- `Dockerfile` is the production image: multi-stage, non-root, Thruster. `config/deploy.yml` is a complete Kamal 2
  configuration whose placeholders are the image owner, server IP, registry user and the
  `APP_HOST`/`SMTP_ADDRESS`/`MAIL_FROM` under `env: clear:`. Its two secrets come from `.kamal/secrets`.

## Testing

- `bin/rails test:all` runs unit, integration and system tests. `bin/rails test` skips system tests.
- Tests run in parallel (`workers: :number_of_processors`). SimpleCov results are merged per worker in
  `test_helper.rb`.
- Line coverage floor is 90%, enforced only when `CI` or `COVERAGE` is set. Branch coverage is reported, not enforced.
- System tests use headless Chrome. Set `CHROME_BINARY=/path/to/chrome` when Chrome is not on `PATH` (WSL, slim
  containers).
- Rate limiting is testable: `config.action_controller.cache_store = :memory_store` in test while the general store is
  `:null_store`; `test_helper.rb` clears it before each test.
- `bin/ci` (`config/ci.rb`) mirrors the remote pipeline locally: setup, RuboCop, bundler-audit, importmap audit,
  Brakeman, `bin/rails test`, `bin/rails test:system` and `db:seed:replant` in the test env. GitHub Actions (`.github/workflows/ci.yml`) runs the scans, lint and
  `bin/rails db:test:prepare test:all` on pull requests and pushes to `master`.

## Conventions

- Conventional Commits in English (`feat:`, `fix:`, `test:`, `chore:`, `ci:`, `refactor:`). Anything that took a
  decision carries a body explaining it. Default branch is `master`.
- `params.expect`, not `permit`, in every controller that takes a form.
- `:role` is permitted in `Admin::UsersController#user_params` and nowhere else;
  self-registration and the profile never accept it. The import reads the role from the spreadsheet instead.
- Admin search is `User.matching`: an exact email when the term contains `@` (deterministic encryption allows it),
  otherwise `full_name LIKE ... ESCAPE`, with the term escaped by `sanitize_sql_like`. The `ESCAPE` clause is what
  makes that escaping mean anything: without it the backslash is a literal, `_` stays a wildcard, and nobody can
  search for a name containing `%` or `_`. Role filter is checked against `User.roles` before it reaches the query.
- RuboCop: omakase plus a stricter layer (`.rubocop.yml`: metrics ceilings, Rails cops, Minitest and Performance
  plugins, line length 120). Run `bin/rubocop -A` after editing Ruby.
- Error responses render with `status: :unprocessable_content`; destroy redirects use `status: :see_other`.
- Submit-button state comes from Turbo's `data-turbo-submits-with`, not from Stimulus. The one Stimulus controller
  (`image_preview`) does what Turbo cannot: reads a chosen `File` client-side and revokes the object URL on disconnect.
- A Content Security Policy of `default-src 'none'` is enforced, with a per-response nonce for scripts and styles and
  `style-src-attr 'unsafe-inline'` for computed widths. Adding an external script or stylesheet means updating
  `config/initializers/content_security_policy.rb`. `ApplicationSystemTestCase` fails any test whose page reports a
  violation — a blocked style breaks the interface without failing a single DOM assertion.
- `ENV["PORT"]` is not the port the app serves on. Foreman gives each Procfile process its own (web 3000, css 3100,
  jobs 3200), and mail is delivered from the jobs process, so links built from PORT point at the worker. Use `WEB_PORT`.
- The admin tables stack into cards below `sm`: the table, head, body, rows and cells all carry `block`/`hidden` with
  an `sm:table-*` counterpart. A four-column row with three actions does not fit 390px, and internal horizontal scroll
  hides the actions behind an edge nobody notices. Keep `dom_id(user)` on the `tr` — the role toggle replaces it.
- Never pass `request.query_parameters` to `url_for`. It hands the router `host`, `protocol` and `controller` from the
  query string: pagination links get rewritten to another domain, and a bad `controller` is a 500.

## Gotchas

- `Procfile.dev` must keep `tailwindcss:watch[always]`. Without `always` the watcher exits when stdin is not a TTY
  (Docker Compose), and foreman takes the whole application down with it.
- `config/cache.yml` needs `database: cache` under development as well as production. Missing it, Solid Cache looks for
  `solid_cache_entries` in the primary database and every `rate_limit` action returns 500 on its first write. The test
  suite never sees this because test uses `:null_store`; `test/config/solid_stack_test.rb` guards it instead.
- `config.active_record.encryption.encrypt_fixtures = true` in `test.rb` is required for fixture emails to match the
  encrypted column.
- `shared/_avatar.html.erb` checks `avatar_image.attachment&.persisted?`, not `attached?`. Re-rendering a form after a
  failed create otherwise asks for a URL to a blob with no id and raises.
- In system tests `click_on` returns before the request completes. `ApplicationSystemTestCase#sign_in_as` waits on
  `has_no_current_path?(new_session_path)` and flunks with the page text, so the next `visit` is not made as an
  anonymous visitor and a failure says why.
- `Dockerfile.dev` has no `USER`, so the container runs as root. `tmp` and `log` are named volumes in `compose.yaml`;
  bind-mounting them leaves root-owned files on the host that block a local `bin/dev` from writing its bootsnap cache.
  Read container logs with `docker compose logs`.
- libvips is only needed for Active Storage variants. Both Docker images and the CI test job install it; a host
  without it runs everything, because avatars do not use variants.
- `sign_in_as` in `test/test_helpers/session_test_helper.rb` writes a cookie into a test request and is for
  integration tests only; system tests use the browser-driven override in `ApplicationSystemTestCase`.
- Turbo's debounce on `broadcasts_refreshes_to` restarts on every write, so a bulk job broadcasts nothing until it
  stops. `SpreadsheetImportJob` suppresses it and paces the refresh itself.
- The cable adapter in test is `async`, not `test`, because system tests need real delivery. That rules out
  `assert_broadcasts` and turbo's own broadcast assertions; Minitest 6 also no longer ships `minitest/mock`.
