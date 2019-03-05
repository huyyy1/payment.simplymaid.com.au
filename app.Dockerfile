FROM ruby:2.5-alpine

ENV RAILS_ROOT /var/www/app_name
ENV RAILS_ENV='production'

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev mysql-client libproj-dev nodejs

RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle check || bundle install --without development test
COPY . .

RUN DB_ADAPTER=nulldb bundle exec rails assets:precompile RAILS_ENV=production

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
