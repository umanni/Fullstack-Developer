# Security design and production checklist

## Trust boundaries

The application treats browser parameters, uploaded files, spreadsheet cells, remote image URLs, cookies, and job arguments as untrusted input. The server never fetches a remote avatar: it stores a validated HTTPS URL and lets the browser request it without a referrer, avoiding a server-side request-forgery boundary.

## Implemented controls

### Authentication and sessions

- Rails 8 generated authentication customized around `User#email` and bcrypt.
- Passwords require at least 12 characters and are never logged.
- Login and password-reset requests are rate limited.
- Responses do not reveal whether an email exists during password recovery.
- Login resets the cookie session before issuing a new signed, HTTP-only, same-site cookie.
- The cookie is marked secure whenever the request is HTTPS, including TLS terminated by the configured production proxy.
- Password changes revoke all persisted sessions.
- Authentication return URLs must parse and match the current host.
- Action Cable rejects connections without a valid persisted session.

### Authorization

- `Admin::BaseController` protects every administrative route.
- Profile routes do not accept a user identifier and always use `Current.user`.
- Visitor registration forces `role: :user` after structural parameter filtering.
- Role changes use a dedicated admin-only endpoint; normal create/update parameters do not accept `role`.
- Deterministic PostgreSQL row locks protect the final-administrator invariant under concurrency.

### Request and output handling

- Rails CSRF protection remains enabled for all state-changing browser requests.
- `params.expect` defines the accepted shape at every mutation boundary.
- Rails output escaping neutralizes stored HTML/script content.
- User search uses bound parameters and `sanitize_sql_like`, so quote and wildcard input cannot alter SQL meaning.
- Content Security Policy defaults to same-origin, blocks objects and framing, limits form targets, and uses a cryptographically random nonce for scripts.
- Production host authorization rejects unexpected host headers; HTTPS deployments enable HSTS/redirect behavior while excluding only the health endpoint.
- Sensitive keys, tokens, passwords, emails, and import payloads are filtered from logs.

### Files and imports

- Avatar uploads accept only JPEG, PNG, or WebP and are limited to 5 MB.
- Remote avatars require HTTPS, a host, no embedded username/password, and at most 2,048 characters.
- Spreadsheet uploads require a matching CSV/XLSX extension and content type and are limited to 5 MB.
- XLSX archives are bounded by entry count, expanded size, and physical sheet rows before cell iteration to limit archive-expansion and sparse-sheet denial of service.
- Parsed imports require explicit columns and at least one but no more than 1,000 data rows.
- Imported attributes are sliced to an allowlist; role values use an explicit mapping.
- Uniqueness races are handled at both model and database-index layers.
- Row errors are truncated before persistence and rendered through normal HTML escaping.
- Successful rows are durable and terminal jobs are idempotent.

### Persistence and secrets

- PostgreSQL foreign keys and check constraints defend critical invariants below the model layer.
- Import history survives creator or imported-user deletion through nullable audit references and database-level `ON DELETE SET NULL` foreign keys.
- Passwords are stored only as one-way bcrypt digests, and no recoverable application secret is persisted in domain tables. Email remains queryable for authentication, search, and a case-insensitive unique index, so it is protected through access control and log filtering rather than ineffective reversible application encryption.
- No production credential or key is committed. `.env`, Rails master keys, and Kamal secrets are ignored.
- SMTP may be read from encrypted Rails credentials or environment variables. Environment variables take precedence.
- The final container runs as an unprivileged user and contains no development/test gem group.

## Verified attack-oriented checks

- SQL-like search input is treated as literal text.
- Stored script-shaped names render escaped and never create executable elements.
- Non-admin requests to admin routes redirect without disclosing admin content.
- Visitor and profile/admin update parameters cannot assign a role.
- Insecure/credential-bearing avatar URLs, unsafe upload types, oversized files, duplicate emails, malformed spreadsheets, and missing columns are rejected.
- Brakeman runs with warning/error exit status; bundler-audit, importmap audit, and CodeQL are delivery gates.

## Production checklist

- Replace all example hosts and registry values in `config/deploy.yml`.
- Generate a strong `SECRET_KEY_BASE`; load registry, database, and SMTP secrets from a password manager.
- Use a dedicated PostgreSQL role and encrypted backups; restrict port 5432 to localhost/private networking.
- Keep `APP_PROTOCOL=https`, confirm proxy TLS/HSTS behavior, and test secure cookies through the real hostname.
- Configure SMTP or intentionally accept file delivery; monitor failed Solid Queue jobs.
- Use S3-compatible Active Storage for multi-host deployments and enforce bucket encryption/lifecycle policy.
- Add centralized error reporting without attaching filtered parameters or spreadsheet payloads.
- Patch base images and gems continuously; keep CI security gates required for merge.
- Define retention/deletion policy for import files, row errors, sessions, finished jobs, and generated mail files.
