FROM ruby:2.6.5-alpine3.9

RUN apk add --update --no-cache --virtual .build-deps build-base libgcrypt-dev \
 libxml2-dev libxslt-dev nodejs postgresql-contrib postgresql-dev
RUN apk add file
RUN apk add clamav-daemon

WORKDIR /usr/src/app

COPY . .

ARG BUNDLE_FLAGS
RUN gem install bundler
RUN bundle install --jobs 4 --retry 5 ${BUNDLE_FLAGS}

RUN apk del .build-deps
RUN addgroup -S appgroup && adduser -S 1001 -G appgroup
RUN chown -R 1001:appgroup .
USER 1001

ARG RAILS_ENV=production
CMD bundle exec rails s -e ${RAILS_ENV} --binding=0.0.0.0
