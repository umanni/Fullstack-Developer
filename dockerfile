FROM ruby:2.7.1

RUN apt-get update -qq --fix-missing && apt-get install -y build-essential libpq-dev nodejs npm
RUN apt-get install -y unzip xvfb libxi6 libgconf-2-4 default-jdk
RUN npm install -g yarn

# === 1 ===
# Install Chrome and Chrome Driver
# Only needed for tests on capybara/selenium

# ARG chromedriver_version=77.0.3865.40
# RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
# RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
# RUN apt-get -y update
# RUN apt-get -y install google-chrome-stable
# RUN curl https://chromedriver.storage.googleapis.com/$chromedriver_version/chromedriver_linux64.zip -o chromedriver_linux64.zip
# RUN unzip chromedriver_linux64.zip
# RUN mv chromedriver /usr/bin/chromedriver
# RUN chmod +x /usr/bin/chromedriver

# === 2 ===
# Add the rails app
RUN mkdir -p /home/app/webapp/tmp/pids
WORKDIR /home/app/webapp
ADD . /home/app/webapp

# === 3 ===
# Create entrypoint
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle

ENV PATH="${BUNDLE_BIN}:${PATH}"
RUN gem install bundler:2.1.4

