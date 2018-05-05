FROM ruby:2.2.4
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /cogli-quiz-creation
WORKDIR /cogli-quiz-creation
ADD Gemfile /cogli-quiz-creation/Gemfile
ADD Gemfile.lock /cogli-quiz-creation/Gemfile.lock
RUN bundle install
ADD . /cogli-quiz-creation

ENV PORT 3000
ENV RAILS_ENV production
ENV RACK_ENV production
ENV APP_DOMAIN quiz-creation.cogliapp.com

RUN rake assets:clobber
RUN rake assets:precompile
