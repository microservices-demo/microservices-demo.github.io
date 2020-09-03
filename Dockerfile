FROM ruby:2.7-alpine

COPY Gemfile .
COPY Gemfile.lock .

RUN apk update && \
    apk add make gcc musl-dev nodejs python2 git g++
RUN bundle install

WORKDIR /srv/jekyll
EXPOSE 4000
ENTRYPOINT ["jekyll", "serve", "--host", "0.0.0.0", "--watch", "--incremental"]
