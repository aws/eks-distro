#!/usr/bin/env bash
# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
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

# This job is run by kop-build-1-X-presubmit, check the last name of the JOB_TYPE is presubmit
# ${JOB_TYPE##*-} strips the presubmit name until the last '-'
if [[ "$AWS_ROLE_ARN" == "" && "${JOB_TYPE:-}" != "presubmit" ]]; then
	echo "Empty AWS_ROLE_ARN, AWS_ROLE_ARN is required if this script is run in a postsubmit pod for IAM Roles for Service Accounts"
	exit 1
fi

if [[ "$TEST_ROLE_ARN" == "" && "${JOB_TYPE:-}" != "presubmit" ]]; then
	echo "Empty TEST_ROLE_ARN, TEST_ROLE_ARN is required if this script is run in a postsubmit pod for IAM Roles for Service Accounts"
	exit 1
fi

BASEDIR=$(dirname "$0")

cat <<EOF >config
[default]
output=json
region=${AWS_REGION:-${AWS_DEFAULT_REGION:-us-west-2}}
role_arn=$AWS_ROLE_ARN
web_identity_token_file=/var/run/secrets/eks.amazonaws.com/serviceaccount/token

[profile conformance-test]
role_arn=$TEST_ROLE_ARN
region=${AWS_REGION:-${AWS_DEFAULT_REGION:-us-west-2}}
source_profile=default
EOF
export AWS_CONFIG_FILE=$(pwd)/config
export AWS_PROFILE=conformance-test
unset AWS_ROLE_ARN AWS_WEB_IDENTITY_TOKEN_FILE
DEFAULT_KOPS_ZONE_NAME="prod-build-pdx.kops-ci.model-rocket.aws.dev"
KOPS_ZONE_NAME=${KOPS_ZONE_NAME:-"${DEFAULT_KOPS_ZONE_NAME}"}
export NODE_ARCHITECTURE=${NODE_ARCHITECTURE:-amd64}
export KOPS_CLUSTER_NAME=${RELEASE_BRANCH}-${NODE_ARCHITECTURE}-$(git rev-parse --short HEAD).$(echo $RANDOM | md5sum | head -c 4).${KOPS_ZONE_NAME}
${BASEDIR}/run_all.sh
