FROM elixir:1.10
LABEL maintainer="yauheni@tsiarokhin.me"

ARG API_TOKEN
ENV JAMESON_API_KEY=$API_KEY

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

ENTRYPOINT ["_build/prod/rel/james/bin/jameson", "start"]

EXPOSE 80
