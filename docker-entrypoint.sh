#!/bin/sh

# save environment variables so they are accessible in cron jobs
env | grep -v "^HOME=" > /etc/environment

if [ "$1" = 'cron' -a "$2" = '-f' ]; then
    echo "Cron job is running to renew all the certs..."
fi

exec "$@"
