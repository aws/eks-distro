#!/usr/bin/env bash
# Copyright 2021 Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    # See https://github.com/awslabs/amazon-ecr-credential-helper/issues/248
    cat $DOCKER_CONFIG/config.json | \
        jq --arg TOKEN $TOKEN '.auths."public.ecr.aws".auth = $TOKEN' > $DOCKER_CONFIG/config.json.new
    cp $DOCKER_CONFIG/config.json.new $DOCKER_CONFIG/config.json
fi
