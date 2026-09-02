# End-to-end QA inventory

This inventory defines the user-visible claims and controls that must be checked before delivery. Automated system coverage is complemented by an interactive browser pass against the production Docker image.

## Visitor journeys

- Landing page: responsive header, product message, sign-in link, and registration call to action.
- Registration: name, email, password confirmation, upload/remote avatar choice, client constraints, server validation errors, and forced standard-user role.
- Authentication: valid/invalid credentials, password visibility, same-host return path, sign-out, and password recovery without account enumeration.

## Standard-user journeys

- Role-aware login redirect to the personal profile.
- Profile only exposes the signed-in user's information.
- Profile edit supports name, email, uploaded avatar, and HTTPS remote avatar with preview/fallback behavior.
- Account deletion requires confirmation, revokes the current session, and cannot mutate another account.
- Admin navigation and endpoints remain inaccessible.

## Administrator journeys

- Role-aware login redirect to the admin dashboard.
- Dashboard shows total, administrator, and standard-user counts and subscribes to a Turbo stream.
- User directory supports responsive list/card layouts, safe name/email search, empty state, pagination, creation, editing, role toggling, and deletion confirmations.
- The final administrator cannot be demoted or deleted.
- CSV and XLSX upload controls enforce type/size limits and provide downloadable templates.
- Imports move through queued/processing/terminal states in Solid Queue, update through Solid Cable, retain durable counters, isolate row failures, and remain idempotent after completion.

## States and presentation

- Success/error flash messages can be dismissed and are exposed as live regions.
- Forms have labels, required/min/max/pattern constraints, visible focus states, and useful backend feedback.
- Remote-image failures reveal initials instead of a broken image.
- Pages have no unintended horizontal overflow at 375 px mobile and 1,400 px desktop widths.
- Primary content, navigation, actions, tables/cards, progress bars, and footer remain visually legible at both widths.

## Verification matrix

| Layer | Coverage |
| --- | --- |
| Models/services/queries/jobs | Minitest, parallel execution, line and branch thresholds |
| HTTP/auth/security boundaries | Rails integration tests |
| Browser journeys | Capybara + Selenium + headless Chromium |
| Interactive presentation | Production Docker image in desktop and mobile browser viewports |
| Static quality | RuboCop, Brakeman, bundler-audit, importmap audit, CodeQL |
| Delivery | Multi-stage Docker build, Compose health checks, PostgreSQL, Solid Queue, Solid Cable, Kamal configuration |
