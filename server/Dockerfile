FROM ruby:2.7.1-slim

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev postgresql less curl && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v 2.1.4

WORKDIR /app
COPY ./Gemfile /app/Gemfile
COPY ./Gemfile.lock /app/Gemfile.lock
RUN bundle install -j4

COPY . /app

EXPOSE 3000

CMD bin/bundle exec rails server -b "0.0.0.0"
