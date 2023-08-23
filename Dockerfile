FROM ruby:3.2.2

WORKDIR /app

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

RUN bundle install

COPY . .

EXPOSE 3000

VOLUME .

CMD ["rails", "s", "-p", "3000"]