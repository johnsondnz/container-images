#!/bin/bash

echo "==> Setup Crontab with $CRON"
echo "$CRONTAB" > /crontab

echo "==> Setup timezone"
cp /usr/share/zoneinfo/$TZ /etc/localtime || echo 'Nothing to do'

# # setup config file
# if [ -f "/config/config.yaml" ]; then
#   sed -i "s/XX_ACCOUNT_ID/$B2_ACCOUNT_ID/g" /config/config.yaml
#   sed -i "s/XX_ACCOUNT_KEY/$B2_ACCOUNT_KEY/g" /config/config.yaml
#   sed -i "s/XX_BUCKET/$B2_BUCKET/g" /config/config.yaml
#   sed -i "s/XX_SUPER_SECRET_KEY/$SUPER_SECRET_KEY/g" /config/config.yaml
# fi

if [ $# -eq 0 ]; then
  echo "==> Initiliase restic"
  autorestic check -c /config/config.yaml --verbose

  echo "==> Parsing and loading cron"
  /usr/bin/crontab /crontab

  echo "==> Get cron settings"
  /usr/bin/crontab -l

  echo "==> Starting crond"
  /usr/sbin/crond -f -d 6

elif [ $1 == 'bash' ]; then
  bash
elif [ $1 == 'shell' ]; then
  bash
elif [ $1 == 'sh' ]; then
  bash
elif [ $1 == 'version' ]; then
  cat /VERSION
fi
