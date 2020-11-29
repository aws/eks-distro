#!/usr/bin/env bash

# Token expires after 12 hours
TOKEN=$(aws --region us-east-1 ecr-public get-authorization-token \
    --output=text \
    --query 'authorizationData.authorizationToken')

DOCKER_CONFIG=${DOCKER_CONFIG:-"~/.docker"}
if [ "$(which docker)" != "" ]; then
    echo $TOKEN | \
        base64 --decode | \
        cut -d: -f2 | \
        docker login -u AWS --password-stdin https://public.ecr.aws
else
    mkdir -p $DOCKER_CONFIG
    if [ ! -f $DOCKER_CONFIG/config.json ]; then
        echo '{}' > $DOCKER_CONFIG/config.json
    fi
    # Gross, abominable hack until ecr-credential-helper supports public ECR
    cat $DOCKER_CONFIG/config.json | \
        jq --arg TOKEN $TOKEN '.auths."public.ecr.aws".auth = $TOKEN' > $DOCKER_CONFIG/config.json.new
    cp $DOCKER_CONFIG/config.json.new $DOCKER_CONFIG/config.json
fi
