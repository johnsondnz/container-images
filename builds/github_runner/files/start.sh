#!/bin/bash

ORGANIZATION=$ORGANIZATION
ACCESS_TOKEN=$ACCESS_TOKEN
GITHUB_USERNAME=$GITHUB_USERNAME
REPOSITORY=$REPOSITORY

if ! [[ -z $ORGANIZATION ]] && ! [[ -z $GITHUB_USERNAME ]]; then
    echo "Set either ORGANIZATION or GITHUB_USERNAME with REPOSITORY, not both... exiting"
    exit 1
fi

org() {
    echo "Entering organization mode..."
    REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)
    ./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN}
}

individual() {
    echo "Entering individual with repository mode..."
    REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/repos/${GITHUB_USERNAME}/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)
    ./config.sh --url https://github.com/${GITHUB_USERNAME}/${REPOSITORY} --token ${REG_TOKEN}
}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

if ! [[ -z $ORGANIZATION ]]; then
    org
elif ! [[ -z $GITHUB_USERNAME ]]; then
    individual
fi

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

exec ./run.sh & wait $!
