FROM ruby:2.5.5
ENV LANG C.UTF-8
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
apt-get install -y nodejs

RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && \
    gem install bundler

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY package.json package.json
RUN bundle install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]

ENV APP_HOME /line_manager
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY . /line_manager
RUN yarn upgrade && \
    gem install foreman && \
    gem install whenever

# command to build docker image ▼
#   docker-compose up --build

# make a database
#   docker-compose run web bundle exec rake db:drop
#   docker-compose run web bundle exec rake db:create
#   docker-compose run web bundle exec rake db:migrate
#   docker-compose run web bundle exec rake initiater:build_data