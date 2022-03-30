#!/bin/bash

if [ $# -eq 0 ]; then
  python3 /app/main.py

elif [ $1 == 'bash' ]; then
  zsh
elif [ $1 == 'shell' ]; then
  zsh
elif [ $1 == 'sh' ]; then
  zsh
elif [ $1 == 'zsh' ]; then
  zsh
fi
