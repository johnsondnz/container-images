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

echo "==> Install GitHub Runner"
mkdir -p /home/generic/actions-runner && cd actions-runner
curl -s https://api.github.com/repos/actions/runner/releases/latest | grep -E "browser_download_url.*linux-x64-([0-9\.]*)\.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
find . -iname 'actions-runner-linux*.tar.gz' -exec tar xzf {} \;

ls -lR /home/generic/actions-runner

echo "==> Install extra dependencies"
sh /home/docker/actions-runner/bin/installdependencies.sh

echo "==> Cleanup"
apt purge -yqq git
apt autoremove -yqq --purge
apt autoclean
rm -rf /var/lib/apt/lists/*
rm /etc/pip-requirements.txt
rm /etc/apt-requirements.txt
