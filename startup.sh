#!/bin/sh
set -e
set -x

if [ -f /opt/Geolite2-City.mmdb ]; then
    export GEOLITE2_DB=/opt/Geolite2-City.mmdb
fi

echo "Starting Sample JSON rules..."
ruller-sample-feature-flag \
    --log-level=$LOG_LEVEL \
    --city-state-db=/opt/city-state.csv \
    --geolite2-db="$GEOLITE2_DB"

