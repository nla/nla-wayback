#!/bin/bash
NLA_ENVIRON=$2

if [[ ! -d "$NLA_ENVIRON" ]]; then
    echo NLA_ENVIRON "'$NLA_ENVIRON'" not found.
    echo It must be set to one of:
    for deploy in */nla-deploy.sh; do
        echo "- ${deploy%%/*}"
    done
    exit 1
fi

cd $NLA_ENVIRON
./nla-deploy.sh "$@"
