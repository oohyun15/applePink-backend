#!/bin/bash

# Rails-specific issue, deletes a pre-existing server, if it exists

# Define commands that you want to be executed whenever container runs.

set -e

rm -f /applePink/tmp/pids/server.pid
rake db:setup
RAILS_ENV=test rake db:setup

exec "$@"
