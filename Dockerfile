# syntax=docker/dockerfile:1
# check=error=true

# Production image, meant for Kamal or a manual build'n'run:
# docker build -t fullstack_developer .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<config/master.key> -e APP_ORIGIN=https://example.com --name fullstack_developer fullstack_developer

# Must match .ruby-version and the `ruby` line in the Gemfile.
ARG RUBY_VERSION=4.0.6
# Must match .nvmrc (CI reads it through actions/setup-node).
ARG NODE_VERSION=26.8.2

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libjemalloc2 libvips postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# jemalloc is only used if preloaded.
ENV RAILS_ENV=development \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    LD_PRELOAD=/usr/local/lib/libjemalloc.so

# ---------- build ----------
FROM base AS build

ARG NODE_VERSION
ENV PATH=/usr/local/node/bin:$PATH

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev libyaml-dev node-gyp pkg-config python-is-python3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    rm -rf /tmp/node-build-master

# -j 1 avoids a QEMU bug when cross-building amd64 on Apple Silicon: https://github.com/rails/bootsnap/issues/495
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

RUN bundle exec bootsnap precompile -j 1 app/ lib/

RUN SECRET_KEY_BASE_DUMMY=1 \
    APP_ORIGIN=http://localhost \
    VITE_RUBY_SKIP_ASSETS_PRECOMPILE_INSTALL=true \
    ./bin/rails assets:precompile

# The browser assets and the SSR server (public/vite-ssr/ssr.js) are both self-contained
# bundles, so the runtime needs the node binary but not node_modules.
RUN rm -rf node_modules

# ---------- final ----------
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails
# Runs the Inertia SSR server, which the inertia_ssr Puma plugin (config/puma.rb) starts.
COPY --from=build /usr/local/node/bin/node /usr/local/bin/node

# Code stays root-owned; the app user can only write where Rails needs to.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p tmp/storage && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
