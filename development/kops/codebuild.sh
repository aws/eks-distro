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

set -o errexit
set -o nounset
set -o pipefail
set -x

if [ "$TEST_ROLE_ARN" == "" ]; then
    echo "Empty TEST_ROLE_ARN, this script must be run in a codebuild job with a test role arn provided"
    exit 1
fi

BASEDIR=$(dirname "$0")

cat << EOF > config
[profile conformance-test]
role_arn=$TEST_ROLE_ARN
region=${AWS_REGION:-${AWS_DEFAULT_REGION:-us-west-2}}
credential_source=EcsContainer
EOF

export AWS_CONFIG_FILE=$(pwd)/config
export AWS_PROFILE=conformance-test
DEFAULT_KOPS_ZONE_NAME="prod-build-pdx.kops-ci.model-rocket.aws.dev"
KOPS_ZONE_NAME=${KOPS_ZONE_NAME:-"${DEFAULT_KOPS_ZONE_NAME}"}
export NODE_ARCHITECTURE=${NODE_ARCHITECTURE:-amd64}
export KOPS_CLUSTER_NAME=${RELEASE_BRANCH}-${NODE_ARCHITECTURE}-$(git rev-parse --short HEAD).$(echo $RANDOM | md5sum | head -c 4).${KOPS_ZONE_NAME}
${BASEDIR}/run_all.sh
