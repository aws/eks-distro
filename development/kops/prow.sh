#!/usr/bin/env bash
# Copyright 2020 Amazon.com Inc. or its affiliates. All Rights Reserved.
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

if [ "$PROW_ROLE_ARN" == "" ]; then
    echo "Empty PROW_ROLE_ARN, this script must be run in a postsubmit pod with IAM Roles for Service Accounts"
    exit 1
fi

if [ "$TEST_ROLE_ARN" == "" ]; then
    echo "Empty TEST_ROLE_ARN, this script must be run in a postsubmit pod with IAM Roles for Service Accounts"
    exit 1
fi

BASEDIR=$(dirname "$0")

cat << EOF > ${BASEDIR}/config
[default]
output=json
region=us-west-2
role_arn=$PROW_ROLE_ARN
web_identity_token_file=/var/run/secrets/eks.amazonaws.com/serviceaccount/token

[profile conformance-test]
role_arn=$TEST_ROLE_ARN
region=us-west-2
source_profile=default
EOF

export AWS_CONFIG_FILE=${BASEDIR}/config
export AWS_DEFAULT_PROFILE=conformance-test
export AWS_ROLE_ARN=${PROW_ROLE_ARN}

${BASEDIR}/run_all.sh
