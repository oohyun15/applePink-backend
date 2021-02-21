#!/bin/bash

# Rails-specific issue, deletes a pre-existing server, if it exists

set -e

rm -f /myapp/tmp/pids/server.pid

exec "$@"
