#!/bin/bash

set -e
PATH=$PATH:~/.local/bin

echo "Configure pre-commit"
pre-commit install --install-hooks

echo "set permissions on gnupg"
sudo chown generic:generic /home/generic/.gnupg

echo "==> Running container version $VERSION"
