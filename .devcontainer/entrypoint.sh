#!/bin/bash

set -e
PATH=$PATH:~/.local/bin

[ -s .pre-commit-config.yaml ] && echo "Configure pre-commit" pre-commit install --install-hooks || echo "==> No pre-commit to install"
[ -s ./.devcontainer/pip-requirements.txt ] && echo "==> Install pip packages" && pip3 install --no-cache-dir -r ./.devcontainer/pip-requirements.txt || echo "==> No additional packages to install"
zsh
