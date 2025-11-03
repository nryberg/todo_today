#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Generate secret key if not provided
if [ -z "$SECRET_KEY_BASE" ]; then
  export SECRET_KEY_BASE=$(bundle exec rails secret)
  echo "Generated SECRET_KEY_BASE for this session"
fi

# Create database if it doesn't exist
if [ ! -f /app/db/production.sqlite3 ]; then
  echo "Creating production database..."
  bundle exec rails db:create RAILS_ENV=production
  bundle exec rails db:migrate RAILS_ENV=production

  # Optionally seed the database
  if [ "$SEED_DB" = "true" ]; then
    echo "Seeding database..."
    bundle exec rails db:seed RAILS_ENV=production
  fi
else
  echo "Database exists, running migrations..."
  bundle exec rails db:migrate RAILS_ENV=production
fi

# Execute the main command
exec "$@"
