#!/bin/bash

echo "==> Setup Crontab with $CRON"
echo "$CRONTAB >/proc/1/fd/1 2>/proc/1/fd/2" > /crontab

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

    echo "==> Starting cron in foreground"
    /usr/sbin/cron -f -l 2
  else
    echo "==> Restic configuration not found in '/config/config/yaml'"
    echo "Exiting..."
    exit 1
  fi

elif [ $1 == 'bash' ]; then
  zsh
elif [ $1 == 'shell' ]; then
  zsh
elif [ $1 == 'sh' ]; then
  zsh
elif [ $1 == 'zsh' ]; then
  zsh
fi
