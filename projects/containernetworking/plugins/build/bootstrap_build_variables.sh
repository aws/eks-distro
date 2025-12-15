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

VPCCNI_TAG=$(aws eks describe-addon-versions \
  --addon-name vpc-cni \
  --kubernetes-version "${RELEASE_BRANCH//-/.}" \
  --query 'addons[0].addonVersions[0].addonVersion' \
  --output text | sed 's/-eksbuild\..*//')

# new version launch case, fallback to previous version until the new version is launched for Addons
if [ "${VPCCNI_TAG}" == "None" ]; then
  PREV_VERSION=$(echo "${RELEASE_BRANCH}" | awk -F'-' '{print $1"-"$2-1}')
  VPCCNI_TAG=$(aws eks describe-addon-versions \
    --addon-name vpc-cni \
    --kubernetes-version "${PREV_VERSION//-/.}" \
    --query 'addons[0].addonVersions[0].addonVersion' \
    --output text | sed 's/-eksbuild\..*//')
fi

PLUGINS_VERSION=$(curl -sL "https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/${VPCCNI_TAG}/Makefile" | grep 'plugins: FETCH_VERSION=' | sed 's/.*FETCH_VERSION=//')
GIT_TAG="v${PLUGINS_VERSION}"
echo "${GIT_TAG}" > "${RELEASE_BRANCH}/GIT_TAG"
echo "${GIT_TAG}" > .git_tag
GOLANG_VERSION=$(curl -sL "https://raw.githubusercontent.com/containernetworking/plugins/${GIT_TAG}/.github/go-version")
echo "${GOLANG_VERSION}" > "${RELEASE_BRANCH}/GOLANG_VERSION"
echo "${GOLANG_VERSION}" > .go-version

curl -sL "https://raw.githubusercontent.com/containernetworking/plugins/${GIT_TAG}/go.mod" -o "${RELEASE_BRANCH}/go.mod"
curl -sL "https://raw.githubusercontent.com/containernetworking/plugins/${GIT_TAG}/go.sum" -o "${RELEASE_BRANCH}/go.sum"
