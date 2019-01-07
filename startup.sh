#!/bin/bash
set -e
set -x

echo "Starting Sample JSON rules..."
sample \
    --log-level=$LOG_LEVEL \
    --geolite2-db=/opt/Geolite2-City.mmdb \
    --city-state-db=/opt/city-state.csv
    
