# Technical Survey — mini Rails 8 IAM + InertiaJS

Living reference document on the technologies and patterns used in this project,
with the rationale behind each choice and examples pointing to file + line. Cross-cutting rules: strict SOLID,
strict DRY, minimal GoF, Clean Code, and the English language throughout **all** the code
(including code docs/comments);

---

## 1. Base stack

| Technology | What it does | Why it was used | Proof in code |
|---|---|---|---|
| Ruby 4.0.6 | Runtime | Stack required by the specification; RVM on the host, `ruby:4.0.6-slim` in the container | `.ruby-version`; `Dockerfile:12` (`FROM docker.io/library/ruby:4.0.6-slim AS base`) |
| Rails 8.0.5.1 | Web framework | Required stack; ships native auth, Solid trio, rate limit, tokens, Thruster/Kamal out of the box | `Gemfile:5` (`gem "rails", "~> 8.0.5", ">= 8.0.5.1"`) |
| SQLite 3 (WAL mode) | Database | SQLite is the permitted default; WAL production-ready; `busy_timeout` for concurrent writes | `config/initializers/sqlite_wal.rb:25` (`raw_connection.execute("PRAGMA journal_mode=WAL")`); `config/database.yml:10` (`timeout: 5000`) |
| Docker multi-stage + Thruster + Kamal | Packaging/deploy | Spec requires a multi-stage Dockerfile compatible with Thruster/Kamal; final image without Node/build | `Dockerfile:12,31,47,73` (base → build-assets → build → final); `Dockerfile:90` (`CMD ./bin/thrust ./bin/rails server`) |
| propshaft | Rails asset pipeline | Added for template parity (task `assets:precompile`); the real assets come from Vite | `Gemfile:5`; `Dockerfile:67` (see §6.1) |
| bcrypt | Password hashing | Base of `has_secure_password` (native Rails auth) | `app/models/user.rb:2` |

---

## 2. Backend — libraries

| Library | What it does | Why it was used | Proof in code |
|---|---|---|---|
| `inertia_rails` | Inertia server-side: renders pages + shares props | Monolithic SPA required (InertiaJS), without a separate JSON API; cache-less pages | `Gemfile:67`; controllers (e.g.: `app/controllers/admin/users_controller.rb:31`) |
| `vite_rails` | Integrates Vite as the app asset pipeline | Spec allows Inertia via Vite; `npm run build` → fingerprinted `public/vite` | `Gemfile:69`; `vite.config.ts:9`; `config/vite.json:3` |
| `roo` + `roo-xls` | Spreadsheet parsing (`.csv`/`.xlsx`/`.xls`) | Asynchronous user import required by the spec | `Gemfile:72,77`; `app/parsers/user_imports/parser/roo.rb:32` |
| `pagy` | Pagination | Community standard; isolated **inside** the Query Object (DIP) | `Gemfile:75`; `app/queries/users/listing_query.rb:22` |
| `solid_cache/queue/cable` | Cache, job queue and realtime on SQLite (no Redis) | Explicit "No Redis" requirement; runs in `storage/` with a volume | `Gemfile:20-22`; `config/database.yml:29-40`; `app/services/dashboard/publisher.rb:16` |
| `simplecov` | Coverage measurement with an 80% gate | Defines the suite's "safety net" | `Gemfile:79`; `test/test_helper.rb:9-28` |
| `brakeman` / `rubocop-rails-omakase` | Security static analysis / lint | Linter rigor (spec) + security | `Gemfile:41,44`; run in CI |

---

## 3. Frontend — libraries

| Library | What it does | Why it was used | Proof in code |
|---|---|---|---|
| React 19 | UI | Pillar of "React integrated via Inertia.js" | `package.json` (`react`, `react-dom`) |
| `@inertiajs/react` + `@inertiajs/vite` | Inertia client + Vite plugin | SPA without redirects; navigation via props | `package.json`; `vite.config.ts:9`; `app/frontend/entrypoints/inertia.tsx:9` |
| Tailwind CSS 4 | Utility-first CSS with `@theme` tokens | Modern CSS framework required; black/white theme via tokens | `app/frontend/styles/base.css:1,6-31` |
| MobX + `mobx-react-lite` | Reactive shared state | Shared/realtime state in stores; mandated by the owner as required | `package.json`; `app/frontend/stores/*`; `app/frontend/lib/cable.ts:26-34` |
| `clsx` + `tailwind-merge` | Tailwind-aware class merging | **Internal** primitives of the `lib/styled` wrapper; never exported | `package.json`; `app/frontend/lib/styled/cn.ts:7` |
| `@rails/actioncable` | Channel client (Action Cable protocol) | Frontend consumes backend Solid Cable channels via its own `useChannel` wrapper | `app/frontend/lib/cable.ts:6,26-34` |
| Vitest + Testing Library | Component tests (pure TS) | Testability of the `lib/styled` wrapper and components | `app/frontend/atoms/Button/Button.test.tsx:25-29` |

---

## 4. Native Rails 8 features leveraged

| Feature | Usage | Proof in code |
|---|---|---|
| Authentication generator (`bin/rails generate authentication`) | Cookie-based session auth + CSRF, customized for roles | `config/routes.rb:3-4` (`resource :session`, `passwords`); `app/controllers/concerns/authentication.rb:16-52` |
| `has_secure_password` | Password hashing via bcrypt | `app/models/user.rb:2` |
| `generates_token_for` | Password reset token with expiration | `app/models/user.rb:9-11`; `app/controllers/passwords_controller.rb:27` |
| `rate_limit` (controller) | Anti brute-force on login/registration (store-backed) | `app/controllers/sessions_controller.rb:3`; `app/controllers/registrations_controller.rb:5` |
| `normalizes` + `enum` | Email downcasing, mapped roles | `app/models/user.rb:7,13-14` |
| Solid trio | Realtime (counters, import bar) + async jobs without Redis | `config/routes.rb` `/cable`; `app/services/dashboard/publisher.rb:8,16`; `app/jobs/user_imports/job.rb:9-11` |
| `parallelize` + `SignInHelper` | Parallel tests + login helper | `test/test_helper.rb:49,34-37` (default 1, see §6.4) |

---

## 5. Adopted patterns

Dependency direction rules (thin controllers → abstractions in the "basement"):
`Routes → Controllers → Form/Query/Policy/Service/Presenter → Value Objects`; models only
hold record invariants; concerns only cross-cutting infrastructure (AuthN/AuthZ).

### 5.1 Form Object — validates + persists **one** use case

Shared base (`ActiveModel::Model`), subclasses validate flow-specific rules.
Write controllers **do not** talk to ActiveRecord directly (DIP).

```ruby
# app/forms/users/form.rb:10-12
validates :full_name, presence: true, length: { maximum: 100 }
# app/forms/users/registration_form.rb:10-12
validates :password, presence: true, length: { in: 8..72 }
```

```ruby
# app/controllers/registrations_controller.rb:18-20
form = Users::RegistrationForm.new(registration_params)
if form.save
```

Hierarchy: `Users::Form` → `Users::RegistrationForm`, `Users::ProfileForm`, `Admin::UserForm`
(`app/forms/`). Each write controller only wires params → form → Inertia response.

### 5.2 Query Object — reading, aggregation and pagination isolated

The same query serves both the initial render **and** the broadcast (DRY). Pagy is hidden here.

```ruby
# app/queries/users/listing_query.rb:10,22
def self.call(scope: User.all, search: nil, page: nil)
  pagy = Pagy.new(count: filtered.count, page: safe_page(filtered.count), limit: PER_PAGE)
# app/queries/dashboard/totals_query.rb:7
def self.call(scope)
```

```ruby
# app/services/dashboard/publisher.rb:16
ActionCable.server.broadcast(STREAM, overview.to_inertia)
```

### 5.3 Policy Object — permissions and role invariants

Own interface that mirrors Pundit (trivial migration if the project grows).

```ruby
# app/policies/users/policy.rb:19-21
def admin?
  @user&.admin?
end
# app/controllers/concerns/authorization.rb:13,17
def current_administrator? = Users::Policy.admin?(Current.user)
def require_admin
```

### 5.4 Service Object — orchestrates multi-step flows with DI

Dependencies enter via the constructor (DIP in action; tests inject fakes).

```ruby
# app/services/user_imports/processor.rb:12-17
def initialize(
  parser_class: UserImports::Parser::Roo,
  form_class: Users::RegistrationForm,
  broadcaster: UserImports::ProgressBroadcaster.new,
  dashboard_publisher: Dashboard::Publisher.new
)
```

Others: `Users::AccountCloser`, `Users::RoleToggler`, `Dashboard::Publisher`,
`UserImports::ProgressBroadcaster` (in `app/services/`).

### 5.5 Value Object — immutable data at the boundaries

Types what crosses the layers (value, without identity).

```ruby
# app/value_objects/users/overview.rb:6,13,15
class Overview
  attr_reader :total_users, :by_role
  def to_inertia
# app/value_objects/user_imports/row_error.rb:7-15
class RowError
  def initialize(row_number:, attribute:, message:)
```

### 5.6 Presenter — single contract with the frontend

Pure presentation (no business rule); the TS types mirror it (front/back DRY).

```ruby
# app/presenters/user_presenter.rb:10
def to_inertia
```

```ts
// app/frontend/types/index.ts:33-36
export type UsersOverview = {
  total_users: number
  by_role: Record<string, number>
}
```

### 5.7 Concern — cross-cutting infrastructure (AuthN/AuthZ)

Session/authorization mixins; no business rules here.

```ruby
# app/controllers/concerns/authentication.rb:16,20,24
def authenticated? = resume_session
def require_authentication
def resume_session
# app/controllers/application_controller.rb:2
include Authentication
```

### 5.8 Job — thin, delegates to the Service

```ruby
# app/jobs/user_imports/job.rb:9-11
def perform(user_import)
  user_import.update!(status: :processing) unless user_import.processing?
  UserImports::Processor.new.call(user_import)
end
```

### 5.9 Callable `.call` — convention, **not** the GoF Command

Objects-that-respond-to-`call` for uniform invocation of queries/services. It is Ruby
idiom, not a design pattern: no state/execute-invoker.

```ruby
# app/queries/users/listing_query.rb:10
def self.call(scope: User.all, search: nil, page: nil)
```

### 5.10 The single permitted strategy — the Parser (registry = data, not object)

The project's only "strategy structure" ("minimal GoF" rule). Two formats with
divergent behavior (encoding/sheets) → single interface + selection by extension via a
hash. Extending a format = adding a line to the table (OCP).

```ruby
# app/parsers/user_imports/parser.rb:8-14
REGISTRY = {
  ".csv" => Roo,
  ".xlsx" => Roo,
  ".xls" => Roo
}.freeze
# app/parsers/user_imports/parser/roo.rb:32
spreadsheet = ::Roo::Spreadsheet.open(path, extension: extension, csv_options: CSV_OPTIONS)
```

No `AbstractFactory`/`Factory` was created: the registry is **data** (frozen hash), not
a GoF object.

### 5.11 Frontend — Atomic Design guaranteed by structure (Phase 7)

Single dependency direction (`atoms ← molecules ← organisms ← pages/templates`). Each
component is a folder with co-located `<Name>.tsx`, `<Name>.types.ts`, `<Name>.test.tsx`
and `<Name>.styles.ts`. Routing is the Inertia mapping to `../pages`.

```
app/frontend/{atoms,molecules,organisms,templates,pages}
```

```tsx
// app/frontend/entrypoints/inertia.tsx:9
pages: '../pages',
// app/frontend/atoms/Button/Button.styles.ts:28
export const StyledButton = styled.button(buttonBase, buttonConfig)
```

### 5.12 Frontend — Tailwind Styled (own wrapper, compile-time)

Own implementation in the style of styled-components, **without** runtime CSS-in-JS:
composition of `clsx` + `tailwind-merge` in `styled(tag, base, {variants, defaults})` and
`css(...)`. Typed variants; transient props do not leak to the DOM. No Tailwind class
on JSX tags — the styling lives in `<Name>.styles.ts`.

```ts
// app/frontend/lib/styled/cn.ts:7
return twMerge(clsx(inputs))
// app/frontend/lib/styled/styled.tsx:38,78
export function styled<TTag extends ElementType, TArgs extends Array<string | VariantConfig>>(
export function css<T>(value: T): T {
```

```tsx
// app/frontend/atoms/Button/Button.tsx:6-7
export function Button({ variant, size, ...rest }: ButtonProps) {
  return <StyledButton variant={variant} size={size} {...rest} />
}
```

### 5.13 Frontend — State with MobX (single store per responsibility)

Observables/computeds/actions in stores injected into the `RootStore` via Context (no
global singleton). The frontend consumes via `useStore()`; nothing of emitters/bus.

```ts
// app/frontend/stores/flash-store.ts:12,20-22
makeAutoObservable(this)
get hasMessage(): boolean {
// app/frontend/stores/store-context.tsx:12-16
export function useStore(): RootStore {
// app/frontend/stores/index.ts:5
configure({ enforceActions: 'always' })
```

### 5.14 Frontend — Realtime: channel (external boundary) → `store.ingest`

Backend broadcasts (Solid Cable) are received by a `useChannel` wrapper and become a
store `action`. No duplicated state snapshot in the component.

```tsx
// app/frontend/organisms/DashboardStats/DashboardStats.tsx:25-27
useChannel<UsersOverview>('DashboardChannel', {}, (payload) => {
  dashboard.ingest(payload)
})
// app/frontend/lib/cable.ts:6,26-34 (createConsumer + subscription.received)
import { createConsumer } from '@rails/actioncable'
```

Corresponding backend: `app/services/user_imports/progress_broadcaster.rb:8`
(`ActionCable::Channel::Base.broadcast_to`) and `app/services/dashboard/publisher.rb:16`.

### 5.15 Back↔Front contract (proof of DRY)

Test that reads the TS types and compares them with the presenters' payload — breaks if
the boundary diverges.

```ruby
# test/contracts/presenter_contract_test.rb:33-35
  it "UserPresenter matches UsersOverview (Dashboard)" do
```

---

## 6. Patterns used with caution

| Item | Caution | Proof in code |
|---|---|---|
| **propshaft** | Added **only** for the `assets:precompile` task (parity with the Rails template) and `SECRET_KEY_BASE_DUMMY` in Docker; every real app asset comes from Vite (`npm run build`), `app/assets/` is empty. It is a deliberately "dead" dependency at runtime — a conscious compliance decision. | `Gemfile:5`; `Dockerfile:67` |
| **`roo-xls`** | Accepts `.xls` beyond the requested `.csv`/`.xlsx` (neutral superset — the required flow works the same). | `Gemfile:77`; `app/parsers/user_imports/parser.rb:8` |
| **`PARALLEL_WORKERS=1` default** | The `parallelize` feature exists (`test/test_helper.rb:49`), but the default is 1 process so the SimpleCov gate is exact (parallel workers dispute `.resultset.json`). Parallelism remains available via `PARALLEL_WORKERS=N` (used 2× in CI). | `test/test_helper.rb:6` |
| **`rate_limit` + Rails.cache** | Rate limit uses `Rails.cache`; in tests it requires `:memory_store` + `Rails.cache.clear` per test (determinism). | `config/environments/test.rb`; `test/test_helper.rb:63` |
| **`ENV.fetch` fail-fast** | `APP_HOST`/`MAIL_FROM` are required in production; the Docker build has build placeholders (best practices) | `config/environments/production.rb:60-67`; `Dockerfile:67` |
| **Registry `.freeze`** | The parser "table" is data, but new extensions require editing the hash (OCP by data). It is the single evolution point. | `app/parsers/user_imports/parser.rb:8` |
| **Authorization without `UserImports::Policy`** | Only `Users::Policy` exists; the admin import session is covered by the `Authorization` concern — the Pundit-like interface is still unique | `app/controllers/concerns/authorization.rb:13` |
| **Solid Cable (Rails) + Action Cable (client)** | Backend uses Solid Cable (SQLite, no Redis); the browser consumes it with `@rails/actioncable` (standard). No SolidJS on the client — realtime delivered at the channel boundary. | `Gemfile:22`; `app/frontend/lib/cable.ts:1,6` |
| **Capybara/Selenium in the Gemfile** | Present (spec asks for robust tests), but system test usage was **deferred** in Phase 10: current coverage is unit + integration (138 tests, 99.9%). | `Gemfile:group :test`; `test/` |

---

## 7. Patterns **left aside** (and why)

### 7.1 Backend

| Pattern/lib | Why it was left aside |
|---|---|
| **Devise** | Rails 8 native auth (`generate authentication`), lighter and with enum roles; Devise is a "heavy/obsolete gem" the spec asks to avoid. |
| **Redis** | Solid Cache/Queue/Cable keep realtime + background on SQLite (spec: *"No Redis installation should be required"*). |
| **Reform / ActiveInteraction** | Pure PORO Form Objects, zero dependency, compatible with Inertia/strong params. |
| **dry-monads** (`Result`/`Maybe`) | Form Objects expose `#save`/`#errors` (ActiveModel convention); services return booleans/errors. |
| **Pundit** | Deferred ("adopt later if it grows"); the `Users::Policy` interface already mirrors Pundit → trivial migration. |
| **Ransack** | Simple search with `ILIKE`/`LIKE` in the Query Objects (YAGNI). |
| **Draper (Decorator)** | Presenters by composition ("minimal GoF" rule). |
| **Repository pattern** | Not Rails idiom; ActiveRecord + Query Objects cover it. |
| **Interactor / Trailblazer** | One Service Object (`UserImports::Processor`) already orchestrates the only multi-step flow. |
| **Model callback for side effects** (e.g.: `after_create → broadcast`) | Side-effect goes through an explicit call in the service/job — deterministic and testable. |
| **Factory/FactoryMethod for the domain** | Form objects create; the Parser registry is data, not a GoF object. |
| **Singleton / Service Locator** | Constructor injection (DIP) with a concrete default and a test fake. |
| **God object / Law of Demeter** | Thin controllers; delegation at the boundary. |
| **System tests (today)** | Gemfile has Capybara/Selenium, but the focus is unit + integration (Phase 10); system stays for a future iteration at no cost. |

### 7.2 Frontend

| Pattern/lib | Why it was left aside |
|---|---|
| **styled-components (deprecated) / emotion** | Heavy runtime CSS-in-JS; the own wrapper is compile-time, SSR-safe and preserves Tailwind purge. |
| **Tailwind inline on JSX tags** | Owner rule: classes only in `<Name>.styles.ts` via `lib/styled` (single typed API). |
| **CSS Modules** | Pure encapsulation; the wrapper delivers a single typed API with Tailwind-aware merge. |
| **Redux/Toolkit** | Boilerplate; MobX covers reactive state with less ceremony. |
| **Zustand / Effector / XState** | MobX was established by the owner; machines/event-sourcing go against the anti-emitter rule. |
| **Mitt/nanoevents/EventEmitter/signals Godot** | **Forbidden**: state propagation is only React (props/Hooks/Context) + MobX reactivity; channel is boundary → `store.ingest`. |
| **React-Query / TanStack Query** | Server-state via Inertia props; realtime via Solid Cable → store. No extra server-state cache. |
| **cva** | Optional and, if adopted, only internally in `lib/styled` (components don't touch it). |
| **Decorator GoF** | Presenters by composition ("minimal GoF" rule). |

---

## 8. Governance and continuous validation

- **Lint/static**: `rubocop-rails-omakase` + `brakeman` clean (99 files, 0 offenses).
- **Ruby tests**: 138 runs / 0 failures; coverage 99.9% (SimpleCov 80% gate) —
  `test/test_helper.rb:9-28`.
- **TS tests**: Vitest (22 `*.test.tsx` suites), including the wrapper's Tailwind-aware
  merge — `app/frontend/atoms/Button/Button.test.tsx:25-29`.
- **Contract**: `test/contracts/presenter_contract_test.rb:6-63` (presenter ↔ TS types).
- **CI**: `PARALLEL_WORKERS=1` + coverage artifact + Docker build; deploy ready for
  `kamal setup` (see `plan2/fase-11.md`).
- **Gold rules**: strict SOLID, strict DRY, minimal GoF, Clean Code, everything in English.