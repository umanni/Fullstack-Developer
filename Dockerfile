# syntax=docker/dockerfile:1
# check=error=true

# Multi-stage build for the user management application.
#
#   base        → shared runtime layer
#   build       → compiles gems and precompiles assets (thrown away)
#   development → adds build tools, dev/test gems and headless Chrome
#   final       → lean production image, runs as non-root behind Thruster
#
# Production build:  docker build -t user_management .
# Development build: docker build --target development -t user_management-dev .

ARG RUBY_VERSION=4.0.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Runtime packages only. libvips backs Active Storage avatar variants,
# postgresql-client is what bin/docker-entrypoint waits on.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"


# ─── Build stage (discarded) ────────────────────────────────────────────────
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

COPY . .

RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Assets are compiled at build time so the production image never needs the
# real credentials: the dummy key satisfies the initializers and is discarded.
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# ─── Development stage ──────────────────────────────────────────────────────
# Used by docker-compose. Application code is bind-mounted, so only the gems
# and system dependencies are baked in.
FROM base AS development

ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="0" \
    BUNDLE_WITHOUT=""

# chromium is what Cuprite drives over CDP for the Capybara system specs.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev libyaml-dev pkg-config \
      chromium fonts-liberation && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BROWSER_PATH="/usr/bin/chromium"

COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache

# uid/gid 1000 matches the common host user, which keeps bind-mounted files
# writable from both sides without a chown dance.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails "${BUNDLE_PATH}"
USER 1000:1000

EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]


# ─── Final production stage ─────────────────────────────────────────────────
FROM base AS final

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80

# Rails 8 serves /up from Rails::HealthController; Thruster fronts it on 80.
HEALTHCHECK --interval=15s --timeout=5s --start-period=40s --retries=5 \
  CMD curl -sf http://localhost/up || exit 1

CMD ["./bin/thrust", "./bin/rails", "server"]
