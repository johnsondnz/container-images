#!/bin/bash

set -e

echo "==> Prepare system"
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt upgrade -yqq
apt install --no-install-recommends -yqq curl software-properties-common gnupg2 git

echo "==> Install any defined pip packages"
[ -s /etc/pip-requirements.txt ] && echo "==> Install more pip packages" && pip3 install --quiet --no-cache-dir -r /etc/pip-requirements.txt || echo "==> No additional packages to install"

echo "==> Install apt packages"
apt update -qq
xargs -a /etc/apt-requirements.txt apt install --no-install-recommends -yqq

echo "==> Install autorestic"
wget -qO - https://raw.githubusercontent.com/CupCakeArmy/autorestic/master/install.sh | bash

echo "==> Symlink autorestic for cron env"
ln -s /usr/local/bin/autorestic /usr/bin/autorestic

echo "==> Cleanup"
apt purge -yqq git
apt autoremove -yqq --purge
apt autoclean
apt clean
rm -rf /var/lib/apt/lists/*
rm /etc/pip-requirements.txt
rm /etc/apt-requirements.txt
