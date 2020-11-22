FROM elixir:1.11.2
LABEL maintainer="yauheni@tsiarokhin.me"

RUN mkdir /data

ARG API_KEY

ENV JAMESON_API_KEY=$API_KEY
ENV JAMESON_DB_FILE=/data/db
ENV JAMESON_STORAGE_FILE=/data/storage

ENV APPDIR=/app \
    APPNAME=jameson \
    MIX_ENV=prod

ADD . $APPDIR
WORKDIR $APPDIR

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
RUN mix release

ENTRYPOINT ["_build/prod/rel/jameson/bin/jameson", "start"]

EXPOSE 80
