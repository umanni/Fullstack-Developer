# User Management App
## 📋 Overview

This project was built for the Fullstack Developer Test at Umanni.
It is a responsive user management application using the latest stack.

## 🚀 Tech Stack

Backend: **Ruby on Rails 7, PostgreSQL**

Frontend: **SCSS + Bulma**

Authentication: **Devise**

Testing: **RSpec, Capybara**

Containerization: **Docker & docker-compose**

## 🧱 Features

Admin can:
- Access dashboard after login
- View total users and users by role
- Create, edit, delete users
- Toggle user roles
- Import users from spreadsheet and track progress

User can:
- View, edit, and delete their own profile

Visitor can:
- Register as a normal user

## 🐳 Run with Docker
```
docker-compose up --build
```

App available at: http://localhost:3000

## ⚙️ Run Locally
```
bundle install
rails db:create db:migrate
bin/dev
```

## 🧪 Run Tests
```
bundle exec rspec
```

## 📄 Notes

Tests coverage ≥ 90%

Includes .gitignore, .dockerignore, and SCSS styling