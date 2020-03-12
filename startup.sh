#!/bin/bash
set -e
set -x

echo "Starting Sample JSON rules..."
sample \
    --log-level=$LOG_LEVEL \
    --city-state-db=/opt/city-state.csv
    # --geolite2-db=/opt/Geolite2-City.mmdb \
    
