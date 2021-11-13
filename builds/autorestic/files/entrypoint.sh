#!/bin/bash

echo "==> Setup Crontab with $CRON"
echo "$CRONTAB" > /crontab

echo "==> Setup timezone"
cp /usr/share/zoneinfo/$TZ /etc/localtime || echo 'Nothing to do'

if [ $# -eq 0 ]; then
  if [ -f /config/config.yaml ]; then
    echo "==> Initiliase restic"
    autorestic check -c /config/config.yaml --verbose

    echo "==> Parsing and loading cron"
    /usr/bin/crontab /crontab

    echo "==> Get cron settings"
    /usr/bin/crontab -l

    echo "==> Starting crond"
    /usr/sbin/crond -f -d 6
  else
    echo "==> Restic configuration not found in '/config/config/yaml'"
    echo "Exiting..."
    exit 1

elif [ $1 == 'bash' ]; then
  bash
elif [ $1 == 'shell' ]; then
  bash
elif [ $1 == 'sh' ]; then
  bash
fi
