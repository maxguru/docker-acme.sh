#!/bin/sh

if [ "$1" = 'crond' -a "$2" = '-f' ]; then
    echo "Cron job is running to renew all the certs..."
fi

exec "$@"
