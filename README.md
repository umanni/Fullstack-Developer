# Fullstack Developer Test - User Management System

## Overview

This is a full-stack Ruby on Rails application for managing users with admin dashboard, real-time updates, and spreadsheet import functionality.

## Tech Stack

- **Backend**: Ruby on Rails 8.0.3
- **Database**: PostgreSQL 15
- **Authentication**: Devise
- **Authorization**: Pundit
- **Background Jobs**: Sidekiq with Redis
- **Realtime**: ActionCable
- **Server-Side Rendering**: Turbo (Hotwire)
- **File Uploads**: Active Storage
- **Spreadsheet Processing**: Roo
- **Frontend**: Bootstrap 5 + SCSS
- **Testing**: RSpec with 90%+ coverage

## Prerequisites

- Docker and Docker Compose
- Ruby 3.3.0 (if running locally)
- PostgreSQL 15
- Redis
- Node.js and npm

## Quick Start with Docker

### Using Docker Compose (Recommended)

1. Clone the repository:
```bash
git clone <repository-url>
cd Fullstack-Developer
```

2. Build and start the services:
```bash
docker-compose up --build
```

3. Create and seed the database:
```bash
docker-compose exec web rails db:create db:migrate
```

4. Create an admin user (optional):
```bash
docker-compose exec web rails console
```

In the Rails console:
```ruby
User.create!(
  full_name: 'Admin User',
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: :admin
)
```

5. Access the application:
- Web: http://localhost:3000
- Sidekiq UI: Add to routes (see configuration below)

## Local Development Setup

### 1. Install Dependencies

```bash
bundle install
npm install
```

### 2. Database Setup

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed data
rails db:seed
```

### 3. Environment Variables

Create a `.env` file or set environment variables:

```bash
DATABASE_HOST=localhost
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=your_secret_key_here
```

### 4. Start Services

In separate terminals:

```bash
# Start Redis
redis-server

# Start Sidekiq
bundle exec sidekiq

# Start Rails server
rails server
```

### 5. Create Admin User

```bash
rails console
```

```ruby
User.create!(
  full_name: 'Admin User',
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: :admin
)
```

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with coverage report
COVERAGE=true bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb
```

Test coverage is configured to require 90% minimum coverage.

## Features

### Admin Features
- Admin dashboard with real-time user statistics
- CRUD operations for users
- Toggle user roles
- Import users from Excel/CSV spreadsheets
- Real-time progress tracking for imports

### User Features
- View and edit own profile
- Upload avatar image or provide URL
- Delete own account

### Visitor Features
- Register as a new user
- Sign in/Sign out

## Spreadsheet Import Format

The spreadsheet import accepts Excel (.xlsx, .xls) or CSV files with the following columns:

- **full_name** (required): User's full name
- **email** (required): User's email address
- **role** (optional): "admin" or "user" (defaults to "user")
- **avatar_url** (optional): URL for user avatar

Example CSV:
```csv
full_name,email,role
John Doe,john@example.com,user
Jane Admin,jane@example.com,admin
```

## Docker Commands

```bash
# Build images
docker-compose build

# Start services
docker-compose up

# Start in background
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f web

# Run Rails commands
docker-compose exec web rails <command>

# Run tests
docker-compose exec web bundle exec rspec

# Access Rails console
docker-compose exec web rails console
```

## Project Structure

```
app/
  channels/          # ActionCable channels
  controllers/       # Controllers (admin, profiles, users)
  jobs/             # Background jobs (Sidekiq)
  models/           # ActiveRecord models
  policies/         # Pundit authorization policies
  services/         # Service objects
  views/            # ERB templates

config/
  initializers/     # Initializers (devise, sidekiq, etc.)

spec/               # RSpec tests
  factories/        # FactoryBot factories
  models/           # Model specs
  controllers/      # Controller specs
  policies/         # Policy specs
```

## Security Features

- CSRF protection
- XSS prevention (input sanitization)
- Strong parameters
- Authorization with Pundit
- Password encryption with bcrypt
- SQL injection prevention (ActiveRecord)

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL is running
- Check database credentials in `config/database.yml`
- Verify Docker containers are healthy: `docker-compose ps`

### Redis Connection Issues
- Ensure Redis is running
- Check `REDIS_URL` environment variable

### Asset Compilation Issues
- Run `rails assets:precompile`
- Check Node.js version (should be 18+)

### Sidekiq Not Processing Jobs
- Check Sidekiq is running: `docker-compose ps sidekiq`
- Check Redis connection
- View Sidekiq logs: `docker-compose logs sidekiq`

## License

This project is a test assignment for full-stack developer position.

