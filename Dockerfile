FROM ruby:2.3-alpine

COPY Gemfile .
COPY Gemfile.lock .

RUN apk update && \
    apk add make gcc musl-dev nodejs python git
RUN bundle install

WORKDIR /srv/jekyll
EXPOSE 4000
ENTRYPOINT ["jekyll", "serve", "--host", "0.0.0.0", "--watch", "--incremental"]
