# Architecture

## Design goals

The system optimizes for explicit business boundaries, safe asynchronous work, and a small operational surface. It is a modular Rails monolith: deployment remains one application image, while namespaces and object responsibilities keep independent concerns replaceable and testable.

The design avoids ceremonial repositories and layers where Active Record already provides the right abstraction. It also avoids microservices because user management, authorization, statistics, and imports share transactional data and have no independent scaling or ownership boundary in this scope.

## Responsibilities

### HTTP layer

Controllers authenticate, authorize, coerce structural parameters with `params.expect`, invoke one use-case/query boundary, and choose a response. They contain no import parsing, role invariant, password generation, or statistics logic.

- `RegistrationsController` creates forced-standard-role visitor accounts.
- `ProfilesController` scopes every operation to `Current.user`.
- `Admin::BaseController` centralizes administrator authorization.
- Admin controllers orchestrate users, imports, and dashboard reads.

### Domain and persistence layer

- `User` owns identity normalization, credential policy, role semantics, and avatar invariants.
- `Session` is a revocable server-side authentication record.
- `UserImport` is the durable import aggregate with counters and lifecycle state.
- `UserImportRow` is an auditable per-row result and idempotency marker.
- PostgreSQL constraints mirror the critical role, length, counter, status, uniqueness, and relationship invariants.

### Use-case services

- `Users::Create`, `Users::Update`, `Users::Destroy`, and `Users::ToggleRole` own account mutations and side effects.
- `Imports::SpreadsheetParser` turns CSV/XLSX content into a normalized immutable row representation.
- `Imports::RowProcessor` maps external role values, creates an invited user, and isolates validation/uniqueness errors.
- `Imports::ProgressUpdater` derives counters from persisted row states rather than trusting in-memory increments.
- `Imports::ProgressBroadcaster` publishes the server-rendered progress component.

Service results are domain records with their validation errors, so controllers do not translate a parallel error model.

### Read models

- `Dashboard::Stats` returns the role totals required by the live dashboard.
- `Users::Search` owns case-insensitive filtering, wildcard escaping, ordering, pagination, and avatar preloading.

### Asynchronous boundaries

`Imports::ProcessJob` runs on the `imports` queue. It persists processing metadata, creates/updates each row, refreshes durable counters, and broadcasts progress. Successful rows are skipped on retry and terminal imports return immediately. Structural parse failures finish as `failed`; row validation failures finish as `completed_with_errors` while successful rows remain committed.

`Dashboard::BroadcastStatsJob` renders one Turbo Stream replacement after account and role changes. During imports it is additionally queued every 25 rows and once at completion to avoid a counter broadcast for every large-import row.

Solid Queue, Solid Cable, and Solid Cache use separate logical PostgreSQL databases. This isolates their schemas and connection roles without adding Redis or separate application services.

## Last-administrator invariant

Demotion and deletion must never remove the final administrator. A validation alone cannot provide this guarantee because two requests can both observe another administrator.

The mutation service opens a transaction and locks all current administrator rows in deterministic primary-key order. A concurrent mutation waits, re-reads the committed set under PostgreSQL's `READ COMMITTED` isolation, and rejects the operation if one administrator remains. Standard-user rows are locked individually. The stable order also avoids two concurrent operations deadlocking while each holds a different administrator row.

## Authentication and authorization flow

The Rails authentication generator was customized to use `email`, server-side `Session` records, and role-aware destinations. A successful login retains only a validated same-host return URL, resets the cookie session to prevent fixation, and creates a new persisted session. Action Cable resolves the same signed session cookie before accepting a connection.

Authorization is intentionally server-side. Navigation visibility improves usability but is never treated as a permission boundary.

## Frontend

Turbo provides navigation, form submissions, confirmations, and stream replacements. Small Stimulus controllers handle password visibility, dismissible notices, avatar preview lifecycle, and broken-image fallback. Server-rendered HTML remains the source of truth, so there is no duplicate JSON state model or client-side authorization logic.

Tailwind switches the directory from a semantic desktop table to mobile cards. Native labels, constraints, progress elements, live regions, focus styles, and confirmation dialogs provide the accessible baseline.

## Deployment topology

The same final Docker image runs two roles:

- `web`: Puma behind Thruster for HTTP compression, caching, and health checks;
- `job`: Solid Queue supervisor and workers.

Compose adds a one-shot setup service so the queue worker cannot start before all four schemas are prepared. Kamal provides equivalent web/job roles, TLS proxying, a PostgreSQL accessory, and a shared volume for a single-host deployment. Ruby 4 ZJIT is enabled only in the lean runtime stage; build/test stages remain deterministic.

## Future evolution

- Move Active Storage to S3-compatible storage before deploying web/job roles to different hosts.
- Add direct-to-cloud uploads if avatar volume or request duration justifies it.
- Add an outbox only if mail/stream delivery must become atomic across infrastructure failures.
- Partition import rows or stream/chunk parser input if limits grow substantially beyond the current 5 MB/1,000-row product boundary.
