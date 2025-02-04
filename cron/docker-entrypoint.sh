#!/bin/sh
set -e

CRONJOB="$CRON_SCHEDULE $COMMAND"

echo "This cron job will be added :"
echo "$CRONJOB"

echo "Installing the cron job..."
echo "##### start ###" > /task.txt
echo "$CRONJOB" >> /task.txt
echo "##### end ###" >> /task.txt
crontab /task.txt

echo "We run the command once (initial check)..."
eval "$COMMAND"

# run the CMD
echo "First sync was successful, starting cron !"
exec "$@"
