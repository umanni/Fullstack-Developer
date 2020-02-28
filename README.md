# Cassiano Blonski Sampaio - 

Codeminer42 Developer

## Dependencies

```
Ruby 2.7.0
Rails 6.0.2.1
Postgres >= 9.1
Node 12.14.1
Bundler 2.1.2
Yarn 1.17.3
```

## Installing

Copy the contents of the `.env.example` and `database.yml.example` to `.env` and `database.yml` then change with the credentials of your local environment.

```console
$ cp .env.example .env
$ cp config/database.yml.example config/database.yml
```

Install gems and packages, setup the database and run.
```console
$ bundle install
$ yarn install
$ rails db:setup
$ bundle exec rspec
$ rails s
```

## Testing

Running tests:

```console
$ bundle exec rake spec
```

## Database

After installation steps the following admin user will be created in database

1. A Admin User

```
E-mail:   admin@example.com
Password: password
```

## Docker

After installation steps the following admin user will be created in database

```
$ cp .env.example .env
$ cp config/database.yml.example config/database.yml
$ docker-compose build
$ docker-compose run web

if needed run:
$ docker-compose run web yarn install --check-files
and then again:
$ docker-compose run web
```

