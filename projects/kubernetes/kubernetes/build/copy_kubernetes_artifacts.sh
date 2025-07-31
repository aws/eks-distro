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

# Create a temporary file to store S3 listing
TEMP_FILE=$(mktemp)
trap 'rm -f $TEMP_FILE' EXIT

# Reduce number of s3 calls by processing local file of output
KUBERNETES_ARTIFACTS_SOURCE_S3="eks-distro-dev-release-artifacts"
S3_PREFIX="kubernetes-${RELEASE_BRANCH}/releases/"
aws s3 ls --recursive "s3://${KUBERNETES_ARTIFACTS_SOURCE_S3}/${S3_PREFIX}" > "$TEMP_FILE"

LATEST_VERSION=$(grep -o 'eks\.[0-9]\+' "$TEMP_FILE" | sort -V | tail -1)

K8S_PATCH_VERSION=$(grep "${LATEST_VERSION}/artifacts/kubernetes/v[0-9]" "$TEMP_FILE" | \
              grep -o 'v[0-9][^/]*' | head -1)

EKS_VERSION=$(grep "${LATEST_VERSION}/artifacts/kubernetes/${K8S_PATCH_VERSION}/artifacts/kubernetes-public/" "$TEMP_FILE" | \
              grep -o 'v[0-9.]\+-eks-[a-z0-9]\+' | head -1)

# Since this executes in a Make context, we need to make it accessible outside of this shell process and can't just export
echo "${EKS_VERSION}" > .eks_version_temp

# Construct the final S3 path to sync
FINAL_PATH="s3://${KUBERNETES_ARTIFACTS_SOURCE_S3}/${S3_PREFIX}${LATEST_VERSION}/artifacts/kubernetes/${K8S_PATCH_VERSION}/artifacts/kubernetes-public/${EKS_VERSION}/"

# Copy to local directory
 aws s3 sync "${FINAL_PATH}" "_output/${RELEASE_BRANCH}/"