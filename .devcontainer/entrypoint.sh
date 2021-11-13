#!/bin/bash

set -e
PATH=$PATH:~/.local/bin

echo "Configure pre-commit"
pre-commit install --install-hooks

echo "==> Install additional pip packages"
[ -s ./.devcontainer/pip-requirements.txt ] && echo "==> Install pip packages" && pip3 install --no-cache-dir -r ./.devcontainer/pip-requirements.txt || echo "==> No additional packages to install"

echo "set permissions on gnupg"
sudo chown generic:generic /home/generic/.gnupg
