FROM ruby:2.5.5
MAINTAINER fullout

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm && \
    npm install -g yarn@1.15.2 && \
    npm install webpack -g && \
    gem install bundler

ENV APP_ROOT /line_manager
WORKDIR $APP_ROOT

ADD ./Gemfile $APP_ROOT/Gemfile
ADD ./Gemfile.lock $APP_ROOT/Gemfile.lock

RUN bundle install && \
    gem install foreman
ADD . $APP_ROOT