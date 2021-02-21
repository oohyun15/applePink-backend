#!/bin/bash

# Rails-specific issue, deletes a pre-existing server, if it exists

# Define commands that you want to be executed whenever container runs.

set -e

rm -f /applePink/tmp/pids/server.pid
bundle exec rake assets:precompile
rake db:migrate
rake db:seed
RAILS_ENV=test rake db:create
RAILS_ENV=test rake db:migrate

exec "$@"
