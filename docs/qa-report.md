# QA report

Validation date: 2026-09-02

## Complete CI gate

Command:

```bash
docker compose --profile tools run --rm test bin/ci
```

Result: passed in 34.38 seconds.

| Check | Result |
| --- | --- |
| RuboCop | 89 files, 0 offenses |
| bundler-audit | 0 known vulnerable gems |
| importmap audit | 0 vulnerable packages |
| Brakeman 8.0.6 | 0 errors, 0 security warnings |
| Zeitwerk eager loading | passed, no warnings |
| Rails model/service/query/job/controller tests | 116 tests, 474 assertions, 0 failures/errors/skips |
| Parallel coverage | 96.73% lines, 87.32% branches |
| Capybara/Selenium system tests | 4 tests, 26 assertions, 0 failures/errors/skips |
| Merged coverage after system tests | 98.54% lines, 88.02% branches |
| Seed replant | passed |

The enforced thresholds are 90% line and 80% branch coverage. The Rails suite used 14 parallel processes; browser tests remained serialized to avoid shared-driver state.

## Production container validation

- Multi-stage `web`, `job`, and one-shot `setup` images built successfully from Ruby 4.0.6.
- Production assets were compiled through Propshaft/Tailwind without a runtime secret.
- The final image runs as UID/GID 1000 and excludes development/test gem groups.
- PostgreSQL prepared independent application, cache, queue, and cable databases.
- The latest primary-database migration completed an explicit down/up round trip in both test and production containers.
- PostgreSQL inspection confirmed `ON DELETE SET NULL` for import creators and imported-user audit references; deleting a real imported QA user preserved and anonymized its row history.
- `/up` returned HTTP 200 and the web container reached healthy state.
- `/`, `/manifest`, and `/service-worker` each returned HTTP 200 from the rebuilt final image.
- `/service-worker` returned HTTP 200 from the final production image.
- The dedicated Solid Queue supervisor started dispatcher, worker, and scheduler processes.
- Runtime inspection confirmed `RubyVM::ZJIT.enabled? == true`.
- Production response headers included CSP, a non-empty random script nonce, `nosniff`, frame protection, and strict referrer policy.
- Worker/web logs contained no job failures or application errors after successful and failed-row imports.
- `bin/kamal config` rendered successfully with non-secret placeholder environment values.

## Interactive browser validation

The production Docker application was reviewed interactively in the in-app Chromium browser in addition to the repeatable Selenium suite.

### Desktop (1,400 × 1,000)

- Landing page hierarchy, navigation, CTA, cards, and footer rendered correctly.
- Admin login persisted through the Turbo redirect and landed on `/admin`.
- Login and password recovery accepted deliberately uppercased, whitespace-padded email input after canonicalization.
- A mismatched password confirmation rendered inline validation with HTTP 422; a valid token reset the password, revoked prior sessions, and allowed login with the new password.
- An unreachable remote avatar produced the intentional “Preview unavailable” state and hid the broken image before submission.
- Dashboard rendered accurate role totals and no browser console warnings/errors.
- Creating and then removing a scoped QA record through the application service changed the open dashboard from 4 → 5 → 4 without a reload, proving the Solid Queue → Solid Cable → Turbo Stream path.
- User search reduced the desktop table to the expected record.
- Admin creation form exposed the intended attributes and kept role mutation separate.
- An import whose administrator had been deleted remained readable and displayed anonymized authorship as `Deleted user`.

### Mobile (375 × 812)

- No horizontal overflow was present on the user form, directory, dashboard, import list, import form, progress view, or profile.
- The desktop user table was hidden and two mobile user cards were visible.
- Dashboard statistics stacked cleanly and primary actions remained reachable.
- CSV/XLSX upload and both template links remained usable.
- Standard-user login landed on `/profile`; admin navigation was absent.
- Direct navigation to `/admin` as a standard user returned to the profile with a visible authorization alert.

### Real background imports

- A queued two-row CSV transitioned to completed with 100%, 2/2 processed, 2 created, and 0 failed on the already-open page.
- A duplicate-email CSV transitioned to completed-with-errors with 100%, 1/1 processed, and an escaped row-level `Email has already been taken` message.
- A fresh one-row CSV uploaded through the native browser file chooser completed asynchronously and created its user.
- The browser observed both state changes without reload while the separate production Solid Queue worker processed them.
- Browser console inspection after the journeys returned no warnings or errors.

## Automated browser journeys

- Visitor registers with a real PNG upload, sees the Stimulus preview, edits the profile, and signs out.
- Administrator creates, searches, promotes, and deletes a user with Turbo confirmation dialogs.
- Administrator imports CSV and sees final progress.
- Administrator imports XLSX and sees final progress.

See [qa-inventory.md](qa-inventory.md) for the complete acceptance surface.
