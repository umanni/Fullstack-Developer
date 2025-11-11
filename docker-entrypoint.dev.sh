#!/bin/bash
set -e

# Function to wait for PostgreSQL
wait_for_postgres() {
  echo "Waiting for PostgreSQL..."
  while ! pg_isready -h postgres -p 5432 -U postgres; do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 1
  done
  echo "PostgreSQL is up - executing command"
}

# Function to setup database
setup_database() {
  echo "Setting up database..."
  bundle exec rails db:create 2>/dev/null || echo "Database already exists"
  bundle exec rails db:migrate
  bundle exec rails db:seed 2>/dev/null || echo "Seeds already run or failed"
}

# Install dependencies
echo "Installing dependencies..."
bundle check || bundle install

# Wait for services
wait_for_postgres

# Setup database if this is the web service
if [ "$1" = "rails" ] && [ "$2" = "server" ]; then
  setup_database
fi

# Execute the main command
exec "$@"