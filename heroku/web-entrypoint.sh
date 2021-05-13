#!/bin/sh
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bin/rake db:has_been_setup && bin/rake db:migrate || bin/rake db:setup

bundle exec rails server -b 0.0.0.0 -p $PORT
