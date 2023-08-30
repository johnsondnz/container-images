#!/bin/bash

set -e

echo "==> Prepare system"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install --no-install-recommends -yqq curl software-properties-common gnupg2

echo "==> Install terraform-docs"
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.15.0/terraform-docs-v0.15.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
install -o root -g root -m 0755 terraform-docs /usr/bin/terraform-docs
rm ./terraform-docs.tar.gz

echo "==> Install hashicorp repo"
curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /tmp/hashicorp.gpg
install -o root -g root -m 644 /tmp/hashicorp.gpg /etc/apt/trusted.gpg.d/
rm /tmp/hashicorp.gpg
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

echo "==> Install any defined pip packages"
[ -s /etc/pip-requirements.txt ] && echo "==> Install more pip packages" && pip3 install --quiet --no-cache-dir -r /etc/pip-requirements.txt || echo "==> No additional pip packages to install"

echo "==> Install docker binary for command/control and local packer builds"
curl -fsSL https://get.docker.com | sh
usermod -aG docker generic

echo "==> Install apt packages"
apt-get update -qq
[ -s /etc/apt-requirements.txt ] && echo "==> Install more apt packages" && xargs -a /etc/apt-requirements.txt apt-get install --no-install-recommends -yqq || echo "==> No additional apt packages to install"

echo "==> Install ms-vsliveshare.vsliveshare prerequisites"
curl -fsSL https://aka.ms/vsls-linux-prereq-script | sh -

echo "==> Install helm and kubectl"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -o /tmp/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null
rm /tmp/kubectl

echo "==> Install helm-diff plugin"
helm plugin install https://github.com/databus23/helm-diff

echo "==> Setup default shell for generic user"
chsh -s $(which zsh) generic

echo "==> Cleanup"
apt-get autoremove -yqq --purge
apt-get autoclean
apt-get clean
rm -rf /var/lib/apt/lists/*
rm /etc/pip-requirements.txt
rm /etc/apt-requirements.txt
