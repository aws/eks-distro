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

# The artifact directory is the full runtime version. Older releases used the
# plain upstream form (v0.7.18-cvefix); decoupled releases use the combined
# form (0.0.66-v0.7.18-cvefix). Accept both, newest first.
GIT_TAG=$(grep -oE "${LATEST_VERSION}/artifacts/${REPO}/[^/]+/" "$TEMP_FILE" | \
              sed -E "s#.*/artifacts/${REPO}/([^/]+)/#\1#" | sort -u | \
              grep -E '^(v[0-9]|[0-9].*-v[0-9])' | sort -V | tail -1)
if [ -z "${GIT_TAG}" ]; then
    echo "ERROR: no artifact directory for ${REPO} under ${S3_PREFIX}${LATEST_VERSION}" >&2
    exit 1
fi
echo "${GIT_TAG}" > .git_tag

# IMAGE_VERSION is the plain upstream version (v0.7.18-cvefix) used only for
# the public image tag. GIT_TAG keeps the full runtime version for S3 paths,
# the source image tag, and validate-cli-version.
if [[ "${GIT_TAG}" =~ ^v[0-9] ]]; then
    IMAGE_VERSION="${GIT_TAG}"
elif [[ "${GIT_TAG}" =~ -(v[0-9].*)$ ]]; then
    IMAGE_VERSION="${BASH_REMATCH[1]}"
else
    echo "ERROR: cannot derive a plain v<version> from GIT_TAG '${GIT_TAG}'" >&2
    exit 1
fi
echo "${IMAGE_VERSION}" > .image_version

ARTIFACTS_SOURCE_S3_PATH="s3://${ARTIFACTS_SOURCE_S3_BUCKET}/${S3_PREFIX}${LATEST_VERSION}/artifacts/${REPO}/${GIT_TAG}/"
echo "${ARTIFACTS_SOURCE_S3_PATH}" > .s3_sync_path

aws s3 cp "${ARTIFACTS_SOURCE_S3_PATH}.go-version" .go-version
