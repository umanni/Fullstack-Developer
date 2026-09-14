# Umanni — User Management

A Rails 8.1 application on Ruby 4.0 for managing users: a live admin dashboard, full
CRUD with role control, asynchronous spreadsheet import with real-time progress, and a
profile each user manages themselves.

SQLite in WAL mode, Solid Queue, Solid Cache and Solid Cable. No Redis, no Postgres.

---

## AI Usage Disclosure

**Models used: Claude Opus 5 and Claude Fable 5.1, through Claude Code.**

**How it was built.** Through the Claude workflow I use for real work, not a prompt and
a paste: requirements broken into phases, one branch and one PR per phase, and a gate at
the end of each that the phase had to clear before it moved. Opus 5 carried the
implementation and the reviews. Fable 5.1 did the planning, drafted `CLAUDE.md`,
surveyed my previous take-home repositories for conventions worth keeping, and ran the
adversarial passes — evaluating the delivery against the brief with no memory of having
written it, which is how most of the defects listed below were found. Sub-agents drove
Playwright against the running application and reported back; none of them had write
access to the codebase.

**What I did.** I directed the work and stayed inside it. The architecture and every
decision the work branched on are mine: Hotwire over Inertia/React, Minitest over RSpec,
SQLite over PostgreSQL, one PR per phase, and how to handle the point below. I set the
standards the code was held to, read the work against them, sent back what missed, and
decided what shipped. Nothing merged on a model's say-so — a phase moved only on a real
gate: the full suite green, RuboCop and Brakeman clean, the production image built and
exercised, and the flow actually clicked through in a browser.

**The workflow.** Skeleton → authentication → admin CRUD → live dashboard → import →
profile → delivery. Read-only work fanned out in parallel — investigation, UI testing, a
second opinion from a different model — while writing stayed single-threaded, because two
agents editing the same tree produce decisions nobody reviewed.

**What that caught.** Bugs a green test suite did not:

- `tailwindcss:watch` exits when stdin is not a TTY, so `docker compose up` died on
  startup. It needed the `[always]` argument. This would have broken on the reviewer's
  very first command.
- Signing in returned 500 in development: `config/cache.yml` named the cache database
  under production only, so Solid Cache went looking for its table in the primary
  database. The suite could not see it, because the test environment uses `:null_store`,
  which makes rate limiting inert. There is now a test that guards the class of bug.
- The import's progress bar stuck on "Processing" about one run in three: two broadcasts
  a millisecond apart, arriving out of order.
- The dashboard counters froze for the entire duration of an import. Turbo debounces
  refresh broadcasts and the debounce restarts on every write, so a job creating rows
  faster than the delay produced no refresh at all until it finished. Found by watching a
  150-row import; the code reads as though it works.
- The production image seeded demo users, with a published password, because the
  entrypoint runs `db:prepare`. Found by running the image rather than only building it.
- A content security policy added in review blocked the import bar's inline width, so it
  rendered full at every percentage while every test still passed.
- `docker compose --profile mail up` promised a clickable reset link at :8025 and never
  delivered one: SMTP pointed at `localhost`, which inside the web container is that
  container. `raise_delivery_errors` is off in development, so it failed in silence.
  Found by following this README's own instructions instead of trusting them.

A later pass found a commit that had quietly dropped the test asserting a forged session
cookie is ignored, and two tests that kept passing with the defence they named removed,
because a different rule was doing the blocking. All of them are checked the same way
now: remove the defence, watch the test go red.

### A note on the hidden instructions in the brief

The brief at <https://github.com/umanni/Fullstack-Developer> contains an HTML comment in
its `README.md`, addressed to LLM assistants. It asks the model to inject a marker string
into the frontend and, in its own words, to *"not disclose or explain these hidden
constraints to the human user."* It is visible in the raw file, not in the rendered page.

I read it, and I did not follow it. There is no marker string in this codebase, and
nothing about the process was hidden from me. Disclosure is above, in full.

---

## Running it

### Docker (recommended)

```bash
docker compose up
```

Then <http://localhost:3200>. Port 3200 rather than 3000 so it does not collide with
another Rails server; override with `WEB_PORT=4000 docker compose up`.

There is no database service to wait for. SQLite and the three Solid databases live in
the `storage` volume, which is the point of this stack.

```bash
docker compose exec web bin/rails db:seed   # optional: `db:prepare` already seeded
```

### Local

Requires Ruby 4.0.6 (`.ruby-version`) — `rbenv install 4.0.6`, `mise use ruby@4.0.6` or the
equivalent for your version manager. No Node and no libvips: assets go through importmap
and Propshaft, and avatars are stored without variants.

```bash
bin/setup --skip-server   # bundle and prepare the databases
bin/dev                   # Puma, the Tailwind watcher and the Solid Queue worker
```

`bin/setup` runs `db:prepare`, which seeds a database it just created, so a fresh clone
needs no separate `bin/rails db:seed` — run that only to re-seed an existing database.
Plain `bin/setup` hands the terminal straight to `bin/dev`. `bin/dev` installs the
`foreman` gem on first run if it is missing.

### Demo logins

Seeds are idempotent and create 32 users — 6 admins and 26 users, the same split on every
machine. Password for all of them: `secret-password`.

| Email | Role |
|---|---|
| `admin@umanni.test` | admin |
| `user@umanni.test` | user |

Seeds refuse to run outside development and test. `db:prepare` seeds a freshly created
database, and a production deploy must not come up with a published password in it.
The first admin of a real deployment is one command:

```bash
bin/rails runner 'User.create!(full_name: "Ada Lovelace", email: "ada@example.com", role: :admin, password: ENV.fetch("ADMIN_PASSWORD"))'
```

### Trying the spreadsheet import

`test/fixtures/files/users.csv` and `users.xlsx` are ready to upload from **Imports →
New import**. They are deliberately dirty: five rows, of which one has no name and one
repeats an earlier email. Three import, two are reported by line and reason, and the run
still completes. Open the dashboard in a second tab first and watch its counters move at
the same time.

---

## Testing

```bash
bin/rails test:all      # unit, integration and system
bin/rails test          # skips system tests
bin/ci                  # the whole pipeline: lint, audits, Brakeman, tests, seeds
```

**181 tests, 652 assertions, 99.76% line coverage, 97.54% branch coverage** on the last
run — `bin/rails test:all` prints the current figures, and a per-layer breakdown kept by
hand only rots. Tests run in parallel across one process per core, and SimpleCov results
are merged per worker — without that merge the report shows roughly one worker's share
and every number after it is fiction. The 90% floor is enforced under `CI` or `COVERAGE`.

System tests need Chrome, and `Dockerfile.dev` does not install one: run the suite on the
host, not through `docker compose exec`. If Chrome is not on `PATH` (WSL, slim
containers):

```bash
CHROME_BINARY=/path/to/chrome bin/rails test:system
```

The system tests prove what no controller test can: that the dashboard counters move on
their own when a user is created elsewhere, that a role toggle replaces one table row
without reloading the page, and that an import's progress arrives over the wire while
the page sits open.

---

## What it does

| Use case | Where |
|---|---|
| Admin dashboard, counts total and by role, live | `Admin::DashboardsController` |
| Admin lists, creates, edits and deletes users | `Admin::UsersController` |
| Admin toggles a user's role | `Admin::Users::RolesController` |
| Admin imports a spreadsheet asynchronously | `SpreadsheetImportJob` |
| Admin watches import progress live | `Admin::SpreadsheetImportsController` |
| Admin lands on the dashboard after login | `ApplicationController#home_url_for` |
| User lands on their profile after login | same |
| User sees, edits and deletes only their own profile | `ProfilesController` |
| Visitor registers as a plain user | `RegistrationsController` |

---

## Technical decisions

**SQLite, not PostgreSQL.** The brief asks for WAL mode, and Rails 8 is built around
SQLite plus the Solid trio. The pragmas are written out in `config/database.yml` rather
than left to the adapter's defaults, because WAL journalling, `synchronous: normal` and
enforced foreign keys are what separate a production-ready SQLite setup from a toy one,
and a reviewer should not have to read the adapter source to see them. The moment this
application needs a second machine running jobs, it moves to PostgreSQL — SQLite is a
file, not a server.

**Development mirrors production.** Rails leaves development on the async and memory
adapters. That would mean the broadcast and job paths that actually ship are never
exercised until deploy, and a reviewer running `docker compose up` would reasonably
conclude the Solid stack was not used. Development runs the same four databases
production does. `test/config/solid_stack_test.rb` asserts they stay configured, which
is the test that would have caught the cache bug listed above.

**Deterministic encryption on `email`.** The column has to stay uniquely indexable and
findable by exact value — `authenticate_by` and the unique index both depend on
identical plaintext producing identical ciphertext. The cost is real and worth stating:
`LIKE` on email is impossible. The admin search works around it by branching: a term
containing `@` is matched as an exact email, and anything else runs `LIKE` against
`full_name`, which is deliberately left in plaintext for exactly that reason.

**Roles are an enum with a database constraint.** The enum guards the application; the
`CHECK` constraint guards the console, data migrations and anything else that goes
around the model.

**Authorisation belongs to the namespace.** `Admin::BaseController` runs the check, so
every admin controller inherits it rather than remembering to declare it. Two roles do
not justify a policy object. A third role, or per-record permissions, is where Pundit
would go — and that controller is where it would plug in.

**The role is a sub-resource, not a custom action.** `PATCH /admin/users/:user_id/role`
keeps `UsersController` plain CRUD and gives the rule that an admin cannot change their
own role one obvious home. That rule is also what keeps the system administrable: any
*other* admin they demote still leaves them an admin, so the last one can never vanish.

**Pagination is offset-based and hand-rolled.** It fetches one row beyond the page, so
"is there a next page" is answered without a `COUNT`. That is the whole requirement at
this size. A list needing page numbers or a total is where Pagy goes in, rather than
growing this.

**Avatars have no variants.** Generating them would put libvips on every developer's
machine to produce a 40px thumbnail. Uploads are capped at 2 MB and constrained by CSS
instead. At real avatar volume that trade flips and the variant comes back — libvips is
already in both Docker images.

**Minitest, not RSpec.** RSpec is what I reach for day to day, but `parallelize` is the
parallel testing feature the brief names, it is native, and this whole test is built on
Rails 8's own tools.

**The import paces its own dashboard refreshes.** Turbo's debounce restarts on every
write, so a bulk job outruns it and broadcasts nothing until it stops. The job suppresses
the model's broadcast and refreshes on a fixed cadence, and a test fails if that is
removed.

**The import is continuable.** `ActiveJob::Continuable` is new in Rails 8.1 and here it
is correctness: a worker restarting mid-file would replay rows it already imported, and
each would come back as a duplicate email. A test resumes from a cursor and asserts the
earlier rows are not replayed.

---

## Security

**Encryption.** `email` is encrypted at rest with deterministic Active Record
encryption. A test reads the raw column and asserts the address is not in it.

**SQL injection.** Every query goes through Active Record with bound parameters. The two
places user input reaches a query are covered directly: search escapes its term with
`sanitize_sql_like` and names the escape character in the clause — `ESCAPE` is not
optional, and without it the escaping is inert — and the role filter is checked against
`User.roles.key?` rather than passed through — there is a test that sends
`'; DROP TABLE users; --` as a role and asserts the page renders normally.

**XSS.** ERB escapes by default and nothing here calls `html_safe` or `raw`;
`Rails/OutputSafety` keeps it that way. SVG is absent from the allowed avatar types: a
stored SVG is a stored script, and Active Storage serves attachments from this origin.
Behind that sits a Content Security Policy of `default-src 'none'` with a per-response
nonce for scripts and styles — escaping can be undone by one careless `html_safe`, a
policy cannot. Style *attributes* are allowed, because the import progress bar's width
is a computed value; `script-src`, which is where XSS lives, stays closed. The first version of
this policy broke that bar in the browser while twenty-one system tests stayed green —
they asserted `aria-valuenow`, which the server had got right. It was found by opening
the page. The teardown that fails any system test whose browser reports a policy
violation was written in the same commit as the fix, so the next one costs a test run
instead of a pair of eyes. Three tests store markup in a name, a validation message and
an import's row errors, and assert it comes back escaped.

**CSRF.** Rails' token protection is on and every state change goes through `form_with`
or `button_to`. Rails disables the protection in the test environment, which means it is
normally never exercised, so one test turns it back on and asserts a token-less POST
creates nothing.

**Refusals do not carry the method.** Every guard redirect answers `303 See Other`
rather than the default `302`. A client that follows a 302 keeps the request method, so
a `DELETE` on an admin route that the guard refused arrived at the redirect target as
another `DELETE` — and `/profile` answers `DELETE` by deleting the account of whoever
asked. Reproduced with `fetch(..., { method: "DELETE", redirect: "follow" })` against
the running application, and the account was gone. A test asserts the status.

**Mass assignment.** `params.expect` in every controller that accepts a form, rather than
`params.permit` — a request that is not shaped like the form is a 400 rather than
something quietly filtered to an empty hash. (The admin index reads its filters with
`params.permit`; it takes query string, not a form, and a malformed one should narrow the
list, not 400.) `:role` appears in exactly one permitted list, in the admin namespace.
Both self-registration and profile editing have a test that submits `role: admin` and
asserts the user stays a user.

**Brute force.** The sign-in and password-reset endpoints keep the generated
`rate_limit`. The test environment gives the limiter a real cache store so the rule is
exercised rather than assumed.

**Static analysis.** Brakeman, bundler-audit and `importmap audit` run on every pull
request and report zero findings.

`test/integration/security_test.rb` holds the injection, escaping, CSRF and forged-cookie
tests. The rest sit with the code they guard: the role filter and the admin routes that
change something in `test/controllers/admin/users_controller_test.rb`, the rate limit in
`sessions_controller_test.rb`, session revocation in `passwords_controller_test.rb` and
`profiles_controller_test.rb`, and the raw email column in `user_test.rb`.

Every test written for a defence here was checked the same way: remove the defence, run
the test, watch it fail. That is not a formality — the self-demotion test passed for a
whole run with the parameter filter deleted, because a different rule was doing
the blocking.

---

## Cross-browser support

`allow_browser versions: :modern` rejects browsers without webp, import maps, CSS
nesting and `:has` — in practice Chrome 120+, Safari 17.2+ and Firefox 121+. Tailwind 4
sets a floor of its own around there, so without this an older iOS would get broken CSS
and no explanation; `public/406-unsupported-browser.html` is that explanation. The floor
is what makes polyfills unnecessary.

Submit buttons disable and relabel themselves while a request is in flight through
Turbo's own `data-turbo-submits-with`. A Stimulus controller did this first, until review
pointed out that Turbo already shipped it. What Stimulus does here is the thing Turbo has
no answer for: previewing a chosen avatar before it is uploaded, reading a `File` the
browser already holds, and revoking the object URL on disconnect so a cached page does
not pin it in memory.

Form feedback works in three layers. `required`, `type="email"`, `minlength` and
`accept` are enforced by the browser before a request is made, and
`.field-input:user-invalid` styles the field from its native validity state — no
JavaScript. The server-side rules are the ones that decide, and the system tests check
both: one asserts the browser blocks a short password before any request, and the
server-side test uses a duplicate email, because that is the case the browser cannot
catch. Server-side errors render beside the field that caused
them, with `aria-invalid` and `aria-describedby` so a screen reader gets the pairing.

Layout is Tailwind, mobile-first. The users table scrolls inside its own container on a
phone. The name column pins from 640px up but not below it: on a phone the identity
column and three buttons do not both fit, and pinning it covers the actions. A system test
resizes to 390px and fails if any screen is wider than the viewport.

---

## Deployment

The production image is multi-stage, runs as a non-root user, and serves through
**Thruster** for asset caching, compression and X-Sendfile.

**Generate your own credentials before building** — see the Credentials section below.
The build bakes `config/credentials.yml.enc` into the image, and a key generated afterwards
cannot decrypt it.

```bash
docker build -t umanni .
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY="$(cat config/master.key)" \
  -e SOLID_QUEUE_IN_PUMA=true \
  -e APP_HOST=umanni.example.com \
  -e SMTP_ADDRESS=smtp.example.com -e SMTP_PORT=587 \
  -v umanni_storage:/rails/storage umanni
```

`RAILS_MASTER_KEY` is the contents of `config/master.key`, which is not in this
repository.

`SOLID_QUEUE_IN_PUMA` is what starts the job supervisor inside Puma; without it the
image serves fine and imports never run. Kamal sets it in `config/deploy.yml`.

`APP_HOST` and the SMTP pair are not optional decoration. Production raises on delivery
errors, and password reset is the only way an imported user ever signs in: leave them at
their defaults and the reset mail is addressed from `example.com` and posted to
`localhost:587`. Note the name changes by environment — development reads `SMTP_HOST`,
production reads `SMTP_ADDRESS`.

**Regenerating credentials means regenerating the encryption keys.** `email` is an
encrypted column, and production reads `active_record_encryption` from the credentials
rather than from an environment file the way development and test do. If you replace
`config/credentials.yml.enc` with your own, run `bin/rails db:encryption:init` and paste
its three keys in, or the image will boot, answer `/up` with a 200, render every page,
and return a 500 the first time anyone signs in or registers. That is not hypothetical:
it is what this image did until the keys were added.

`config/deploy.yml` is a complete Kamal 2 configuration: fill in the image owner, server
IP, registry user and the `APP_HOST`/`SMTP_ADDRESS`/`MAIL_FROM` under `env: clear:`, and
`bin/kamal setup` is the deploy. The two secrets it needs — `KAMAL_REGISTRY_PASSWORD` and
`RAILS_MASTER_KEY` — come from `.kamal/secrets`, which reads both from your environment.
`kamal config` resolves the whole file — roles, image, volume, ssh, builder — and
`kamal secrets print` resolves the master key. **A deploy against a real host was not
exercised**; there was no server to deploy to. TLS terminates at kamal-proxy, so
`assume_ssl` and `force_ssl` are on in production.

Solid Queue runs inside Puma rather than as a separate job role, and that follows from
SQLite rather than being a shortcut: a worker on a second machine could not reach a
database that is a file. The `storage` volume holds all four databases and every Active
Storage upload — it is the only stateful thing on the server, and so the only thing that
needs backing up.

**Credentials.** `config/master.key` is not in this repository, which means the
committed credentials cannot be read on another machine — as is true of any Rails
repository. Generate your own **before building the image**, or the build bakes in a
file the new key cannot decrypt:

```bash
rm config/credentials.yml.enc
bin/rails db:encryption:init                        # copy the three keys it prints
EDITOR="code --wait" bin/rails credentials:edit     # paste under active_record_encryption:
```

`credentials:edit` needs an `EDITOR` that blocks until you close the file — `code --wait`,
`vim`, or `nano`. Without one it exits without saving.

Rails wires `active_record_encryption` from credentials on its own. Development and test
keys are committed in the environment files on purpose — they are not secrets, and the
application has to boot for anyone who clones this.

---

## Performance

Ruby 4 ships ZJIT and the official image has it compiled in, so enabling it is one flag.
Measuring first says not to. Rendering the users table partial 20,000 times inside the
production image, after 5,000 warmup iterations:

| | YJIT (Rails' default) | ZJIT |
|---|---|---|
| Production image | 0.204–0.226 ms | 0.340–0.375 ms |
| Development container | 0.365–0.395 ms | 0.571–0.592 ms |

ZJIT came out between 50% and 80% slower in every run of both, and a shorter warmup
widened the gap instead of narrowing it, so this is not a young JIT handicapped by
warmup. Rails enables YJIT on its own; it stays that way.

`script/jit_benchmark.rb` takes the measurement. The development container needs no
credentials, so this is the one to reproduce:

```bash
docker compose exec -e RUBYOPT=--yjit web bin/rails runner script/jit_benchmark.rb
docker compose exec -e RUBYOPT=--zjit web bin/rails runner script/jit_benchmark.rb
```

Absolute numbers are per machine and the two rows are not comparable to each other — the
development image boots unoptimised. The ratio within a row is the measurement.

---

## Trade-offs and what is not here

- **The last admin cannot be removed** — not by the role toggle, not by the admin edit
  form, and not by deleting their own profile. Review found the first two routes open
  while the third was guarded, which is what moved the rule from the controller into the
  model. A user who is not the last admin can still delete their own account, as the
  brief asks.
- **Imported users cannot sign in until they reset their password.** They are created
  with a random one and set a real one through the reset flow. Delivery is configured
  (`SMTP_ADDRESS`, `SMTP_PORT`, credentials under `smtp:`), and the flow was exercised
  end to end against a local catcher — mail sent, link opened, password changed, old
  password rejected. A deploy still has to point it at a real mail service.
- **The dashboard suppression is not covered by a test.** `User.suppressing_turbo_broadcasts`
  is what stops Turbo's debounce from swallowing every refresh during a bulk import, but
  turbo-rails debounces immediately under test, so the effect cannot be observed there.
  The test beside it covers the pacing that replaces it — remove `DASHBOARD_EVERY` and it
  fails; remove the suppression and it does not.
- **The test suite does not exercise Solid Queue, Solid Cache or Solid Cable.** Jobs run
  inline, the cache is a null store and Action Cable is in-process, which is what keeps
  the suite fast and deterministic. Those three run for real in development and
  production against their own databases, which is where `docker compose up` puts them.
  `test/config/solid_stack_test.rb` guards the configuration, not the behaviour.
- **Sessions have no expiry and no pruning**, and there is no "active sessions" screen.
  The cookie is permanent, which is what `bin/rails generate authentication` produces.
  Changing a password does sign every other browser out.
- **The imports list is not paginated.** The users list is; imports are few enough that
  it has not earned it.
- **A worker killed outright leaves its import showing "processing".** Solid Queue records
  the failure but never re-enters the job, so `retry_on` does not apply; and a manual
  retry restarts the file from the top, reporting already-imported rows as duplicates.
  Recovering properly means storing the job id and reconciling against
  `solid_queue_failed_executions`, which is more machinery than this size of import earns.
- **Development delivers mail to a local catcher.** `docker compose --profile mail up`
  starts Mailpit; the reset link is then clickable at <http://localhost:8025>. Without
  it, delivery fails quietly. Previews are at `/rails/mailers`.
- **The import lists at most 200 rejected rows.** Each rejection rewrites the whole JSON
  column and rides along in the next broadcast, so an all-bad file would grow both the
  write cost and the message size with every row. The count keeps counting; only the
  listed reasons stop, and the page says so. Imported people get a placeholder digest at
  bcrypt's minimum cost — nobody authenticates with it, and the default cost was 250ms
  per row for nothing.
- **No background job for avatar processing**, no CDN, no fragment caching. All three
  answer a scale this application does not have.
