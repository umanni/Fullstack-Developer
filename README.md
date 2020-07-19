
# UserManager
---------------------------

# Setup

## Pre-requisites

* Ruby 2.6.5
* Bundler 2.1.4
* Docker and Docker Composer (just needed if you want to run the project easily)
* Rails 6.0.3.1
* Postgresql 10.10 or later
* Redis 3.0 or later

## Setup Docker and Docker Composer
First install docker
1. `$ sudo apt install docker.io`
1. `$ sudo systemctl start docker`
1. `$ sudo systemctl enable docker`

To check installation, run:
`$ sudo docker -v`

Then install docker-compose

1. `$ sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`
1. `$ sudo chmod +x /usr/local/bin/docker-compose`

To check installation, run:
`$ docker-compose --version`

## Setup project with docker

1. `$ git clone https://github.com/raicg/user_manager`
1. `$ cd user_manager`
1. `$ cp config/database.yml.sample config/database.yml`
1. `$ cp .env.sample .env`
1. `$ docker-compose run app bundle exec rake db:create`
1. `$ docker-compose run app bundle exec rake db:migrate`

## Running locally with docker

1. `$ docker-compose build`
1. `$ docker-compose up`
1. `$ docker-compose run app bundle exec rails s -b 0.0.0.0`

## Setup project without docker
1. `$ git clone https://github.com/raicg/user_manager`
1. `$ cd user_manager`
1. `$ cp config/database.yml.sample config/database.yml`
1. `$ cp .env.sample .env`
1. `$ bundle install`
1. `$ yarn install`

To continue you will need to open an postgresql server and update config/database.yml file.

Then:

1. `$ bundle exec rails db:create`
1. `$ bundle exec rails db:migrate`

After this you will need to open an redis server and update the .env file with the redis ip.

And then you will need to open 2 servers, the worker and the web:

1. `$ bundle exec sidekiq -C config/sidekiq.yml`
1. `$ bundle exec rails s`

