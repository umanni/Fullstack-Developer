FROM codeminer42/ci-ruby:2.7
#FROM ruby:2.7

RUN gem install bundler:2.1.2
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN npm install -g yarn

RUN bundle install
RUN yarn install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

-e POSTGRES_PASSWORD=password

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
