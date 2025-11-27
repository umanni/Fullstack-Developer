FROM ruby:3.3.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  postgresql-client \
  nodejs \
  npm \
  imagemagick \
  libvips42 \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy package.json and install node modules (if exists)
COPY package.json package-lock.json* ./
RUN npm install || true

# Copy application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=dummy rails assets:precompile

# Expose port
EXPOSE 3000

# Start server
CMD ["rails", "server", "-b", "0.0.0.0"]

