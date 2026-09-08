# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t mini_rails8_iam_with_inertia_js .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name mini_rails8_iam_with_inertia_js mini_rails8_iam_with_inertia_js

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=4.0.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away stage that compiles the Vite/React frontend with just Node.
# Segregated from the Ruby build so gem, bundler and Node caches never
# invalidate each other, and the final image keeps no Node tooling.
FROM node:22-slim AS build-assets

# Rails app lives here (mirrors the base stage layout)
WORKDIR /rails

# Locked npm packages first: the largest, most stable layer to cache
COPY package.json package-lock.json ./
RUN npm ci

# Application source (vite.config.ts, config/vite.json, app/frontend)
COPY . .

# Compile entrypoints to public/vite (see config/vite.json and package.json)
RUN npm run build

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY vendor/* ./vendor/
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code (the built frontend stays in build-assets)
COPY . .

# Bring in the frontend compiled by the Node stage
COPY --from=build-assets /rails/public/vite /rails/public/vite

RUN SECRET_KEY_BASE_DUMMY=1 VITE_RUBY_SKIP_ASSETS_PRECOMPILE_EXTENSION=true APP_HOST=example.com MAIL_FROM=deploy@example.com ./bin/rails assets:precompile

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
