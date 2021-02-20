FROM ruby:2.7.2-alpine

RUN apk update && apk add build-base nodejs yarn postgresql-dev postgresql-client bash tzdata

RUN mkdir /app

COPY . /app

WORKDIR /app

RUN gem install bundler && bundle install && yarn install
