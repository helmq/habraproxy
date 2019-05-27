FROM ruby:2.5.3

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN mkdir -p /proxy
WORKDIR /proxy

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 3

COPY . /proxy

ENV PORT 3000
EXPOSE 3000
CMD bundle exec shotgun config.ru -o 0.0.0.0 -p 3000