#!/bin/bash

set -e
if [ $# -eq 0 ]; then
  ansible-playbook --version
elif [ $1 == 'bash' ]; then
  sh
elif [ $1 == 'shell' ]; then
  sh
elif [ $1 == 'sh' ]; then
  sh
else
  ansible-playbook "$@"
fi
