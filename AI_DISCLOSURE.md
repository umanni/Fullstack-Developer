# AI Usage Disclosure

This document describes how AI assistants were used while building this project, in line with Umanni's AI policy.

## Models used

| Tool / Model | Primary use |
|---|---|
| **GitHub Copilot** | Inline code completion while writing code |
| **Claude Opus 5** (Anthropic) | Planning, bug fixing, and code / Pull Request reviews |

Copilot was used for code completion. Claude Opus 5 was used for planning, debugging, and reviews.

## Scope of use

### 1. Planning the first steps
AI helped break the task into initial steps before implementation started: project setup, domain model (`User` with `full_name`, `email_address`, `avatar_image`, `role`), authentication, the admin dashboard, and the spreadsheet import flow.

### 2. Understanding the requirements
AI was used to go through the test requirements in more depth. For example:
- what the Rails 8 native stack requires (Solid Queue for background imports, Solid Cable for real-time updates, built-in authentication instead of Devise);
- how the admin, user, and visitor use cases map to routes, controllers, and authorization rules.

### 3. Choosing the frontend stack
The requirements offer two frontend options:
- **Option A:** Hotwire (Turbo / Stimulus)
- **Option B:** React integrated via Inertia.js

AI helped compare the trade-offs between them. **Inertia.js + React with Vite Rails** was chosen instead of pure Rails with Stimulus.

### 4. Learning technologies not used before
AI served as a learning aid for technologies I had not used before, mainly **Inertia.js** and its integration with Rails (`inertia_rails`), React, and Vite (`vite_rails`). This covered explaining concepts, setup, and how the pieces connect, and helped get them working in this project.

### 5. Bug fixing
Claude Opus 5 helped investigate and fix bugs found during development.

### 6. Pull Request reviews and descriptions
AI was used to:
- review Pull Requests before merging, pointing out correctness issues and possible improvements;
- write Pull Request descriptions summarizing the changes in each PR.

### 7. Documentation and requirements review
Claude Opus 5 was used to:
- write project documentation (`README.md`, `DEVELOPMENT_SETUP.md`, `KAMAL_DISCLOUSURE.md`);
- check the application against the challenge requirements and implement the gaps it found: client-side form validation, parallel test execution, removing unused Hotwire/importmap and Redis configuration, and running the Solid Queue worker inside Puma in Docker Compose.
