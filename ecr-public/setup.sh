#!/usr/bin/env bash

function install_ecr_public {
    if [ ! -f ~/.aws/models/ecr-public/2020-10-30/service-2.json ]
    then
        BASEDIR=$(dirname "$0")
        aws configure add-model \
          --service-model file://${BASEDIR}/ecr-public-2020-10-30.api.json \
          --service-name ecr-public
    fi
}

install_ecr_public
