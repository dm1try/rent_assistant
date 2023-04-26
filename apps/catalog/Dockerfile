FROM ruby:3.2.2

WORKDIR /app

RUN gem install bundler -v '~> 2.4.10'
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . /app


CMD ["bundle", "exec", "ruby", "main.rb"]
