#!/bin/bash

set -e

echo "==> Prepare system"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install --no-install-recommends -yqq curl software-properties-common gnupg2 git

echo "==> Install any defined pip packages"
[ -s /etc/pip-requirements.txt ] && echo "==> Install more pip packages" && pip3 install --quiet --no-cache-dir -r /etc/pip-requirements.txt || echo "==> No additional packages to install"

echo "==> Install apt packages"
apt-get update -qq
xargs -a /etc/apt-requirements.txt apt-get install --no-install-recommends -yqq

echo "==> Install GitHub Runner"
mkdir -p /opt/actions-runner && cd /opt/actions-runner
curl -s https://api.github.com/repos/actions/runner/releases/latest | grep -E "browser_download_url.*linux-x64-([0-9\.]*)\.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
find . -iname 'actions-runner-linux*.tar.gz' -exec tar xzf {} \;
find . -iname 'actions-runner-linux*.tar.gz' -exec rm {} \;

echo "==> Set ownership of /opt/actions-runner"
chown -R generic:generic /opt/actions-runner

echo "==> Install dependencies"
bash /opt/actions-runner/bin/installdependencies.sh

echo "==> Install docker binary for command/control and packer builds"
groupadd -g 998 docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker generic

echo "==> Install hashicorp repo"
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

echo "==> Cleanup"
apt-get autoremove -yqq --purge
apt-get autoclean
apt-get clean
rm -rf /var/lib/apt/lists/*
rm /etc/pip-requirements.txt
rm /etc/apt-requirements.txt
