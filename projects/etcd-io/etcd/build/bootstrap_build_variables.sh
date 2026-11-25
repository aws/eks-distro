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
S3_BUCKET="eks-distro-dev-release-artifacts"
S3_PREFIX="kubernetes-${RELEASE_BRANCH}/releases/"
aws s3 ls --recursive "s3://${S3_BUCKET}/${S3_PREFIX}" > "$TEMP_FILE"

PLATFORM_VERSION=$("$(git rev-parse --show-toplevel)/build/lib/resolve_platform_version.sh" "${RELEASE_BRANCH}" "$TEMP_FILE")
S3_PATH="${S3_PREFIX}${PLATFORM_VERSION}/artifacts/etcd"

aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}/.git_tag" .git_tag
aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}/.go-version" /tmp/.go-version

GOLANG_VERSION=$(cut -d. -f1,2 < /tmp/.go-version)
# Go 1.25 and older no longer receive upstream security fixes, so every release branch
# builds etcd with at least Go 1.26.
MIN_GO_VERSION="1.26"
if [[ "$(printf '%s\n' "$MIN_GO_VERSION" "$GOLANG_VERSION" | sort -V | head -1)" != "$MIN_GO_VERSION" ]]; then
  GOLANG_VERSION="$MIN_GO_VERSION"
fi
echo "$GOLANG_VERSION" > .go-version

GIT_TAG=$("$(dirname "$0")/effective_git_tag.sh" "${RELEASE_BRANCH}" "$(cat .git_tag)")
echo "$GIT_TAG" > .git_tag
curl -sL "https://raw.githubusercontent.com/etcd-io/etcd/${GIT_TAG}/server/go.mod" -o "${RELEASE_BRANCH}/server/go.mod"
curl -sL "https://raw.githubusercontent.com/etcd-io/etcd/${GIT_TAG}/server/go.sum" -o "${RELEASE_BRANCH}/server/go.sum"
curl -sL "https://raw.githubusercontent.com/etcd-io/etcd/${GIT_TAG}/etcdctl/go.mod" -o "${RELEASE_BRANCH}/etcdctl/go.mod"
curl -sL "https://raw.githubusercontent.com/etcd-io/etcd/${GIT_TAG}/etcdctl/go.sum" -o "${RELEASE_BRANCH}/etcdctl/go.sum"
