FROM ruby:2.6.2

RUN echo "alias vi=vim"  >> /etc/profile

# Install NodeJS v12, Yarn
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Instala nossas dependencias
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
nodejs yarn build-essential libpq-dev imagemagick git-all nano

# Set our path
ENV INSTALL_PATH /umanniApi
# Create our directory
RUN mkdir -p $INSTALL_PATH
# Set our path with main directory
WORKDIR $INSTALL_PATH
# Copy our Gemfile to inside the container
COPY Gemfile ./
# Set our path to the Gems
ENV BUNDLE_PATH /gems
# Copy our code to inside the container
COPY . .