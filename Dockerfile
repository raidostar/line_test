FROM ruby:2.5.5

ENV APP_ROOT /my_app
RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev mysql-client nodejs npm && \
  npm install -g n && \
  n stable && \
  npm install -g yarn && \
  ln -s /usr/bin/nodejs /usr/bin/node

RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile ${APP_ROOT}/Gemfile
ADD Gemfile.lock ${APP_ROOT}/Gemfile.lock
RUN bundle install

ADD package.json $APP_ROOT
ADD yarn.lock $APP_ROOT
RUN yarn install --frozen-lockfile

ADD . $APP_ROOT

RUN bundle exec rake assets:precompile