# syntax=docker/dockerfile:1
# check=error=true

# Fullstack Developer — Rails 8 / Ruby 4.0 / SQLite + Solid Queue/Cable/Cache + Thruster
# Uso:
#   Prod: docker build -t fullstack_vanilla . && docker run -d -p 80:80 -e RAILS_MASTER_KEY=$(cat config/master.key) fullstack_vanilla
#   Dev : docker compose up --build
#   Dev (prod-like): docker compose --profile prod up --build

ARG RUBY_VERSION=4.0.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Pacotes base em produção
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV LD_PRELOAD="/usr/local/lib/libjemalloc.so" \
    BUNDLE_PATH="/usr/local/bundle"

# ------------------------------------------------------------------
# Stage: development — para docker compose com bind mount + live reload
# ------------------------------------------------------------------
FROM base AS development

ENV RAILS_ENV="development" \
    BUNDLE_WITHOUT=""

# Dependências para compilar gems nativas (nokogiri, sqlite3, etc) e Node se precisar
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips libyaml-dev pkg-config curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Instala gems (cache melhorado: copia só Gemfile primeiro)
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache

COPY . .

# Precompile bootsnap e build Tailwind para que o asset exista mesmo com volumes anônimos / .dockerignore
RUN bundle exec bootsnap precompile -j 1 app/ lib/ || true
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails tailwindcss:build

EXPOSE 3333

# Em dev o Solid Queue roda dentro do Puma quando SOLID_QUEUE_IN_PUMA=1
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3333"]

# ------------------------------------------------------------------
# Stage: build —throw-away para produção (gems + assets precompilados)
# ------------------------------------------------------------------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development:test"

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

COPY . .

RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Assets sem precisar de master.key real
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# ------------------------------------------------------------------
# Stage: production — imagem final enxuta e não-root
# ------------------------------------------------------------------
FROM base AS production

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="1" \
    RAILS_LOG_TO_STDOUT="1"

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /rails/storage /rails/tmp/pids /rails/log && \
    chown -R rails:rails /rails/storage /rails/tmp /rails/log

USER 1000:1000

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build --chown=rails:rails /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 CMD curl -f http://localhost:80/up || exit 1

# Thruster na frente do Puma (proxy + cache/compressão)
CMD ["./bin/thrust", "./bin/rails", "server"]
