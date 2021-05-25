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

set -e
set -x

BASE_DIRECTORY=$(git rev-parse --show-toplevel)
RELEASE_BRANCH=$(cat "${BASE_DIRECTORY}"/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT=${RELEASE_ENVIRONMENT:-production}
RELEASE=$(cat "${BASE_DIRECTORY}"/release/"${RELEASE_BRANCH}"/"${RELEASE_ENVIRONMENT}"/RELEASE)
RELEASE_TAG="eks-${RELEASE_BRANCH}-${RELEASE}"

RELEASE_CRD="https://distro.eks.amazonaws.com/kubernetes-${RELEASE_BRANCH}/kubernetes-${RELEASE_BRANCH}-eks-${RELEASE}.yaml"
ECR_BASE="public.ecr.aws/eks-distro"

RELEASE_GIT_TAG=$(cat "${BASE_DIRECTORY}"/projects/kubernetes/release/GIT_TAG)

while read -r image_uri; do
  docker pull "$image_uri"
done < <(curl "${RELEASE_CRD}" | sed -n -e "s|^.*uri: \\($ECR_BASE\\)|\1|p")

# These are not in the CRD
docker pull "${ECR_BASE}/kubernetes/kube-proxy-base:${RELEASE_GIT_TAG}-${RELEASE_TAG}"
docker pull "${ECR_BASE}/kubernetes/go-runner:${RELEASE_GIT_TAG}-${RELEASE_TAG}"
