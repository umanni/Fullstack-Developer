# README

# Umanni Fullstack Developer Test — User Management App

A fullstack Ruby on Rails application for managing users, with authentication, role-based access and realtime updates.

This project was developed as part of the **Umanni Fullstack Developer Test**.

---

## Features

- User registration
- Profile management
- Admin dashboard
- Realtime updates
- Spreadsheet import
- Imports progress tracking 
- Authentication using **Devise**
- Code quality enforced via **Rubocop**
- Test coverage with **RSpec**

---

## Tools

| Tool | Version |
|------|---------|
| Ruby | 3.3.5 |
| Rails | 8.0.4 |
| PostgreSQL | 16.10 |

---

## Gems and Libraries

| Gem | Purpose |
|-----|---------|
| devise | User authentication |
| dart-sass-rails | SCSS compilation |
| image_processing | ActiveStorage image transformations |
| rubocop | Code linting |
| rspec-rails | Testing framework |
| factory_bot_rails | Factories for tests |
| faker | Fake data for tests |
| csv | Import CSV files |
| kaminari | Pagination |

---

## Running the App (Local)

### 1. Install dependencies
```bash
bundle install
```

### 2. Set up the database
```bash
rails db:create db:migrate
```

### 3. Seed Admin User
```bash
rails db:seed
```

| email | password |
|------|---------|
| `admin@umanni.test` | `admin123` |

### 4. Start the server
```bash
bin/dev

or

bin/rails s
```

App will be running at:
http://localhost:3000

---

## Running the App with Docker

### 1. Build the containers
```bash
docker compose build
```

### 2. Start the containers
```bash
docker compose up -d
```

App will be running at:
http://localhost:3000

---

## Developer

**Ivan G. Pagani Fernandes**  
Fullstack Developer — Ruby on Rails

[GitHub](https://github.com/IvanPagani) | [LinkedIn](https://www.linkedin.com/in/ivan-pagani-fernandes/)

---

## License

This project is for **evaluation purposes** under the *Umanni Fullstack Developer Test* and is **not licensed for production use**.