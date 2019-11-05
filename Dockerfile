FROM ruby:2.5.5

ENV APP_ROOT /my_app

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm && \
    npm install -g yarn@1.15.2 && \
    gem install bundler

WORKDIR $APP_ROOT

ADD Gemfile* $APP_ROOT/
RUN bundle install --without development

ADD package.json $APP_ROOT
ADD yarn.lock $APP_ROOT

RUN yarn add @vue/cli-service
RUN bin/rails webpacker:install 
RUN bin/rails webpacker:install:vue
RUN yarn add axios
RUN yarn add vue-router
RUN yarn add vue-template-compiler
RUN yarn add vuex
RUN yarn add vue-eslint-parser

ADD . $APP_ROOT

RUN bundle exec rake assets:precompile