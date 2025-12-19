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
set -eux

TEMP_FILE=$(mktemp)
trap 'rm -f $TEMP_FILE' EXIT
ARTIFACTS_SOURCE_S3_BUCKET="eks-distro-dev-release-artifacts"
S3_PREFIX="kubernetes-${RELEASE_BRANCH}/releases/"
aws s3 ls --recursive "s3://${ARTIFACTS_SOURCE_S3_BUCKET}/${S3_PREFIX}" > "$TEMP_FILE"

# if we move to utilize platform version in EKS-D releases then we can also export this variable
LATEST_VERSION=$(grep -o 'eks\.[0-9]\+' "$TEMP_FILE" | sort -V | tail -1)

GIT_TAG=$(grep "${LATEST_VERSION}/artifacts/${REPO}/v[0-9]" "$TEMP_FILE" | \
              grep -o 'v[0-9][^/]*' | head -1)
echo "${GIT_TAG}" > .git_tag

ARTIFACTS_SOURCE_S3_PATH="s3://${ARTIFACTS_SOURCE_S3_BUCKET}/${S3_PREFIX}${LATEST_VERSION}/artifacts/${REPO}/${GIT_TAG}/"
echo "${ARTIFACTS_SOURCE_S3_PATH}" > .s3_sync_path

aws s3 cp "${ARTIFACTS_SOURCE_S3_PATH}.go-version" .go-version
