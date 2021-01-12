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

set -x
set -o errexit
set -o nounset
set -o pipefail

RELEASE_BRANCH="$1"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
KUBERNETES_ROOT="${MAKE_ROOT}/projects/kubernetes/kubernetes"
KUBERNETES_RELEASE_BRANCH="${KUBERNETES_ROOT}/${RELEASE_BRANCH}"

if [ ! -d "${KUBERNETES_RELEASE_BRANCH}/patches" ]; then
    echo "${KUBERNETES_RELEASE_BRANCH}/patches does not exists. Please add patches for new version."
    exit 0
fi

if [ ! -f "${KUBERNETES_RELEASE_BRANCH}/GIT_TAG" ]; then
    echo "${KUBERNETES_RELEASE_BRANCH}/GIT_TAG does not exists. Please add a GIT_TAG for new version."
    exit 0
fi

if [ ! -f "${KUBERNETES_RELEASE_BRANCH}/RELEASE" ]; then
    echo "${KUBERNETES_RELEASE_BRANCH}/RELEASE does not exists. Please add RELEASE for new version."
    exit 0
fi

RELEASE_VERSION=$(cat "${KUBERNETES_RELEASE_BRANCH}/RELEASE")
GIT_TAG=$(cat "${KUBERNETES_RELEASE_BRANCH}/GIT_TAG")

DOCKER_BUILDKIT=1 docker build --target build --build-arg RELEASE_BRANCH="$RELEASE_BRANCH" --build-arg KUBERNETES_ROOT="projects/kubernetes/kubernetes" \
    -f "${MAKE_ROOT}/build/update-kubernetes-version/Dockerfile" -t  "eks-distro-local-kubernetes-update:${GIT_TAG}-${RELEASE_VERSION}" .

DOCKER_BUILDKIT=1 docker build --target export --build-arg RELEASE_BRANCH="$RELEASE_BRANCH" --build-arg KUBERNETES_ROOT="projects/kubernetes/kubernetes" \
    -f "${MAKE_ROOT}/build/update-kubernetes-version/Dockerfile" --output $KUBERNETES_RELEASE_BRANCH .
