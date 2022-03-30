#!/bin/bash

set -e

echo "==> Prepare system"
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt install --no-install-recommends -yqq curl software-properties-common gnupg2

echo "==> Install terraform-docs"
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.15.0/terraform-docs-v0.15.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
install -o root -g root -m 0755 terraform-docs /usr/bin/terraform-docs
rm ./terraform-docs.tar.gz

echo "==> Install terraform and packer repo"
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

echo "==> Install any defined pip packages"
[ -s /etc/pip-requirements.txt ] && echo "==> Install more pip packages" && pip3 install --quiet --no-cache-dir -r /etc/pip-requirements.txt || echo "==> No additional packages to install"

echo "==> Install apt packages"
apt update -qq
xargs -a /etc/apt-requirements.txt apt install --no-install-recommends -yqq

echo "==> Install ms-vsliveshare.vsliveshare prerequisites"
curl -fsSL https://aka.ms/vsls-linux-prereq-script | sh -

echo "==> Cleanup"
apt autoremove -yqq --purge
apt autoclean
apt clean
rm -rf /var/lib/apt/lists/*
rm /etc/pip-requirements.txt
rm /etc/apt-requirements.txt
